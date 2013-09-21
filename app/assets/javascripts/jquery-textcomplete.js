/**
 * jQuery.textcomplete.js
 *
 * Repositiory: https://github.com/yuku-t/jquery-textcomplete
 * License:     MIT
 * Author:      Yuku Takahashi
 */

;(function ($) {

  'use strict';

  /**
   * Exclusive execution control utility.
   */
  var lock = (function () {
    var table, i;
    table = {};
    i = 0;
    return function (func) {
      var id;
      id = i;
      i += 1;
      return function () {
        var args, free;
        if (table[id]) return;
        table[id] = true;
        free = function () { table[id] = false; };
        args = [free];
        func.apply(this, args.concat(toArray(arguments)));
      };
    };
  })();

  /**
   * Convert arguments into a real array.
   */
  var toArray = function (args) {
    var i, l, result;
    result = [];
    for (i = 0, l = args.length; i < l; i++) result[i] = args[i];
    return result;
  };

  /**
   * Bind the func to the context.
   */
  var bind = function (func, context) {
    if (func.bind) {
      // Use native Function#bind if it's available.
      return func.bind(context);
    } else {
      return function () {
        func.apply(context, arguments);
      };
    }
  };

  /**
   * Default template function.
   */
  var identity = function (obj) { return obj; };

  /**
   * Textarea manager class.
   */
  var Completer = (function () {
    var html, css;

    html = {
      wrapper: '<div class="textcomplete-wrapper"></div>',
      list: '<ul class="dropdown-menu"></ul>'
    };
    css = {
      wrapper: {
        position: 'relative',
        display: 'inline-block'
      },
      list: {
        position: 'absolute',
        top: 0,
        left: 0,
        zIndex: '100',
        display: 'none'
      }
    };

    function Completer(el, strategies) {
      var $wrapper, $list;

      $wrapper = $(html.wrapper).css(css.wrapper);
      $list = $(html.list).css(css.list);

      this.el = el;
      this.$el = $(el);
      this.$el.wrap($wrapper).before($list);
      this.listView = new ListView($list, this);
      this.strategies = strategies;

      this.$el.on('keyup', bind(this.onKeyup, this));
      this.$el.on('keydown', bind(this.listView.onKeydown, this.listView));

      // Global click event handler
      $(document).on('click', bind(function (e) {
        if (!e.originalEvent.internal) {
          this.listView.deactivate();
        }
      }, this));
    }

    $.extend(Completer.prototype, {

      /**
       * Show autocomplete list next to the caret.
       */
      renderList: function (data) {
        if (!this.listView.shown) {
          this.listView.setPosition(this.getCaretPosition());
        }
        data = data.slice(0, this.strategy.maxCount);
        this.listView.render(this.strategy, data);
      },

      // Callbacks
      // =========

      searchCallbackFactory: function (free) {
        var self = this;
        return function (data) {
          self.renderList(data);
          free();
        };
      },

      /**
       * Keyup event handler.
       */
      onKeyup: function (e) {
        var searchQuery, term;

        searchQuery = this.extractSearchQuery(this.getTextFromHeadToCaret());
        if (searchQuery.length) {
          term = searchQuery[1];
          if (this.term === term) return; // Ignore shift-key or something.
          this.term = term;
          this.search(searchQuery);
        } else {
          this.term = null;
          this.listView.deactivate();
        }
      },

      onSelect: function (value) {
        var pre, post;
        pre = this.getTextFromHeadToCaret();
        post = this.el.value.substring(this.el.selectionEnd);
        pre = pre.replace(this.strategy.match, this.strategy.replace(value));
        this.el.value = pre + post;
        this.el.focus();
        this.el.selectionStart = this.el.selectionEnd = pre.length;
      },

      // Helper methods
      // ==============

      /**
       * Returns caret's relative coordinates from textarea's left top corner.
       */
      getCaretPosition: function () {
        // Browser native API does not provide the way to know the position of
        // caret in pixels, so that here we use a kind of hack to accomplish
        // the aim. First of all it puts a div element and completely copies
        // the textarea's style to the element, then it inserts the text and a
        // span element into the textarea.
        // Consequently, the span element's position is the thing what we want.

        if (!this.el.selectionEnd) return;
        var css, styles, i, l, div, $div, span, $span, position;

        css = {
          position: 'absolute',
          overflow: 'auto',
          'white-space': 'pre-wrap',
          top: 0,
          left: -9999
        };
        styles = ['border-bottom-width', 'border-left-width',
          'border-right-width', 'border-top-width', 'font-family',
          'font-size', 'font-style', 'font-variant', 'font-weight',
          'height', 'letter-spacing', 'word-spacing', 'line-height',
          'padding-bottom', 'padding-left', 'padding-right', 'padding-top',
          'text-decoration', 'width'];
        for (i = 0, l = styles.length; i < l; i++) {
          css[styles[i]] = this.$el.css(styles[i]);
        }

        $div = $('<div></div>').css(css).text(this.getTextFromHeadToCaret());
        $span = $('<span></span>').text('&nbsp;').appendTo($div);
        this.$el.before($div);
        position = $span.position();
        position.top += $span.height() - this.$el.scrollTop();
        $div.remove();
        return position;
      },

      getTextFromHeadToCaret: function () {
        return this.el.value.substring(0, this.el.selectionEnd);
      },

      /**
       * Parse the value of textarea and extract search query.
       */
      extractSearchQuery: function (text) {
        // If a search query found, it returns used strategy and the query
        // term. If the caret is currently in a code block or search query does
        // not found, it returns an empty array.

        var name, strategy, match;
        for (name in this.strategies)
            if (this.strategies.hasOwnProperty(name)) {
          strategy = this.strategies[name];
          match = text.match(strategy.match);
          if (match) { return [strategy, match[strategy.index]]; }
        }
        return [];
      },

      search: lock(function (free, searchQuery) {
        var term, strategy;
        this.strategy = searchQuery[0];
        term = searchQuery[1];
        this.strategy.search(term, this.searchCallbackFactory(free));
      })

    });

    return Completer;
  })();

  /**
   * Dropdown menu manager class.
   */
  var ListView = (function () {

    function ListView($el, completer) {
      this.$el = $el;
      this.index = 0;
      this.completer = completer;

      this.$el.on('click', 'a', bind(this.onClick, this));
    }

    $.extend(ListView.prototype, {
      shown: false,

      render: function (strategy, data) {
        var html, i, l, val;
        this.data = data;
        l = data.length;
        if (l) {
          html = '';
          for (i = 0; i < l; i++) {
            val = data[i];
            html += '<li><a data-value="' + val + '">';
            html +=   strategy.template(val);
            html += '</a></li>';
          }
          this.$el.html(html);
          this.index = 0;
          this.activate();
        } else {
          this.deactivate();
        }
      },

      activateIndexedItem: function () {
        var $item;
        this.$el.find('.active').removeClass('active');
        this.getActiveItem().addClass('active');
      },

      getActiveItem: function () {
        return $(this.$el.children().get(this.index));
      },

      activate: function () {
        if (!this.shown) {
          this.$el.show();
          this.shown = true;
        }
        this.activateIndexedItem();
      },

      deactivate: function () {
        if (this.shown) {
          this.$el.hide();
          this.shown = false;
          this.data = this.index = null;
        }
      },

      setPosition: function (position) {
        this.$el.css(position);
      },

      select: function (value) {
        this.completer.onSelect(value);
        this.deactivate();
      },

      onKeydown: function (e) {
        var $item;
        if (!this.shown) return;
        if (e.keyCode === 38) {         // UP
          if (this.index === 0) {
            this.deactivate();
          } else {
            e.preventDefault();
            this.index -= 1;
            this.activateIndexedItem();
          }
        } else if (e.keyCode === 40) {  // DOWN
          if (this.index === this.data.length - 1) {
            this.deactivate();
          } else {
            e.preventDefault();
            this.index += 1;
            this.activateIndexedItem();
          }
        } else if (e.keyCode === 13 || e.keyCode === 9) {  // ENTER or TAB
          e.preventDefault();
          this.select(this.getActiveItem().children().data('value'));
        }
      },

      onClick: function (e) {
        e.originalEvent.internal = true;
        this.select($(e.target).data('value'));
      }
    });

    return ListView;
  })();

  $.fn.textcomplete = function (strategies) {
    var name, strategy;
    for (name in strategies) if (strategies.hasOwnProperty(name)) {
      strategy = strategies[name];
      if (!strategy.template) {
        strategy.template = identity;
      }
      if (strategy.index == null) {
        strategy.index = 2;
      }
      strategy.maxCount || (strategy.maxCount = 10);
    }
    this.each(function () {
      new Completer(this, strategies);
    });

    return this;
  };

})(window.jQuery);
