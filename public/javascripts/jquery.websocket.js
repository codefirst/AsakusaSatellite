(function($) {
    jQuery.fn.webSocket = function(config){
        /*
        Pusher.log = function(message) {
            if (window.console && window.console.log) window.console.log(message);
        };y
        WEB_SOCKET_DEBUG = true;
        */

        var pusher = AsakusaSatellite.pusher;
        var target = this;
        function fire(name, data){
            target.trigger(name, data);
        }

        pusher.connection.bind('connected',
                     function(e) {
                         fire('websocket::connect', e);
                     });
        pusher.connection.bind('failed',
                     function(e){
                         fire('websocket::error', e);
                     });
        pusher.connection.bind('disconnected',
                     function(e){
                         fire('websocket::disconnect', e);
                     });

        var channel = pusher.subscribe('as:' + AsakusaSatellite.current.room );
        channel.bind('message_create',
                     function(obj){
                         fire('websocket::create', obj.content);
                     });

        channel.bind('message_update',
                     function(obj){
                         fire('websocket::update', obj.content);
                     });

        channel.bind('message_delete',
                     function(obj){
                         fire('websocket::delete', obj.content);
                     });
        return this;
    }
})(jQuery);
