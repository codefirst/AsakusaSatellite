/**
 * connect message_pusher events to websocket::* .
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * connect message_pusher events to websocket::* .
     * @param {Object} config.pusher message pusher object like Pusher, Keima, Socky
     * @return this
     */
    $.fn.webSocket = function(config){
        var target = this;

        var pusher = config.pusher;

        function fire(name, data){
            target.trigger(name, data);
        }

        function parse(obj) {
            if(typeof(obj) == 'string') {
                return $.parseJSON(obj);
            } else {
                return obj;
            }
        }

        pusher.connection.bind('connected',
            function(e) { fire('websocket::connect', e); }
        );
        pusher.connection.bind('failed',
            function(e){ fire('websocket::error', e); }
        );
        pusher.connection.bind('disconnected',
            function(e){ fire('websocket::disconnect', e); }
        );

        var channel = pusher.subscribe('as-' + config.room );
        channel.bind('message_create',
            function(obj){ fire('websocket::create', parse(obj).content); }
        );
        channel.bind('message_update',
            function(obj){ fire('websocket::update', parse(obj).content); }
        );
        channel.bind('message_delete',
            function(obj){ fire('websocket::delete', parse(obj).content); }
        );

        return this;
    }
})(jQuery, document);
