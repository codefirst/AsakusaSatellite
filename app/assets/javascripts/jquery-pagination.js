/**
 * pagination utility.
 * @author codefirst
 */
(function($, document, undefined){
    /**
     * add event handler for pagination.
     * @param {String} config.indicator HTML string to indicate loading
     * @param {String} config.url request URL with ajax. it returns HTML content.
     * @param {String} config.content selector for find each messages
     * @param {function} config.append function appends DOM content
     * @param {function} config.params function added to get query
     * @return this
     */
    $.fn.pagination = function(config) {
        var config = $.extend({
            indicator : "",
            content : "div"
        }, config);
        var target = this;

        function activate(elem, f){
            elem.one('click',function(){
                f($(this), function(){ activate(elem, f); });
            });
        }

        var original = target.text();
        activate(target, function(elem, resume){
            target.addClass("loading").empty().html(config.indicator);
            var params = [];
            if (typeof(config.params) === "function")
                $.each(config.params(), function(k,v){
                    params.push(k + "=" + encodeURIComponent(v));
                });

            $.get( config.url + "?" + params.join("&"), function(response){
                var messages = [];
                switch(typeof(response)) {
                case 'string':
                    messages = $( response ).find(config.content);
                    break;
                case 'object': case 'json':
                    messages = $( response.map(function(m){return m.view;}).join("") );
                    break;
                }

                elem.removeClass("loading");
                if(messages.length == 0){
                    elem.empty().html("no more message");
                } else {
                    target.trigger('pagination::load', [ messages ]);

                    messages.hide();
                    config.append(messages);
                    messages.fadeIn();
                    elem.empty().html(original);

                    resume();
                }
            });
        });

        return this;
    };
})(jQuery, document);
