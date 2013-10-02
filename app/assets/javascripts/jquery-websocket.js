/**
 * notify message_pusher event to clients via websocket and postMessage
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * notify message_pusher event to clients via websocket and postMessage
     * @param {Object} config.pusher message pusher object like Pusher, Keima, Socky
     * @return this
     */
    $.fn.webSocket = function(config){
        var target = this;

        var pusher = config.pusher;

        function fire(name, data){
            function isMessageEvent(name){
                return (name == "create" || name == "update" || name == "destroy");
            }

            target.trigger("websocket::"+name, data);

            if(window.postMessage) {
                window.postMessage({ 'type': name,
                                     'current': AsakusaSatellite.current,
                                     'data': data
                                   }, location.protocol+"//"+location.host);
            }
        }

        function parse(obj) {
            if(typeof(obj) == 'string') {
                return $.parseJSON(obj);
            } else {
                return obj;
            }
        }

        pusher.connection.bind('connected',
            function(e) { fire('connect', e); }
        );
        pusher.connection.bind('failed',
            function(e){ fire('error', e); }
        );
        pusher.connection.bind('disconnected',
            function(e){ fire('disconnect', e); }
        );

        var channel = pusher.subscribe('as-' + config.room );
        channel.bind('message_create',
            function(obj){ fire('create', parse(obj).content); }
        );
        channel.bind('message_update',
            function(obj){ fire('update', parse(obj).content); }
        );
        channel.bind('message_delete',
            function(obj){ fire('delete', parse(obj).content); }
        );

        return this;
    }
})(jQuery, document);
