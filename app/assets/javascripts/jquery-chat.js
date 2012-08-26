/**
 * websocket::* event manager.
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * add websocket::* event handlers.
     * @param {fucntion} config.make function converts message JSON to HTML
     * @return this
     */
    $.fn.chat = function(config){
        var target = this;

        target.bind('websocket::create', function(_, obj) {
            var dom = $( config.make(obj) );
            target.append(dom);
            dom.hide();
            dom.fadeIn();
        });

        target.bind('websocket::update', function(_, obj) {
            var dom = $( config.make(obj) );
            dom.hide();
            $("[message-id=" + obj.id + "]", target).replaceWith(dom);
            dom.fadeIn();
        });

        target.bind('websocket::delete', function(_, obj){
            var dom = $("[message-id=" + obj.id + "]", target);
            dom.fadeOut(function(){ dom.remove(); });
        });

        return target;
    }
})(jQuery, document);
