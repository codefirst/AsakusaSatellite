//= require jquery-append-hack
/**
 * connect as::* events to other handlers
 * @author codefist
 */
(function($, document, undefined) {
    /**
     * fire function f to selected elements.
     * bind as::* events to f
     * @param {String} selector selector string
     * @param {function} f function to be fired.
     * @return this
     */
    $.fn.watch = function(selector, f){
        var target = this;

        target.find(selector).each(function(_, e){
            f($(e));
        });

        var handler = function(_,elems){
            $(elems).filter(selector).each(function(_, e){
                f($(e));
            })
        };

        target.bind("as::append"     ,handler);
        target.bind("as::prepend"    ,handler);
        target.bind("as::before"     ,handler);
        target.bind("as::replaceWith",handler);
        return this;
    }
})(jQuery, document);
