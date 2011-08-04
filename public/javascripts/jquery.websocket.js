(function($) {
    jQuery.fn.webSocket = function(config){
        /*
        Pusher.log = function(message) {
            if (window.console && window.console.log) window.console.log(message);
        };y
        WEB_SOCKET_DEBUG = true;
        */

        var pusher = new Pusher('f36e789c57a0fc0ef70b');
	var target = this;
	function fire(name, data){
	    target.trigger(name, data);
	}

        pusher.bind('pusher:connection_established',
	             function(e) {
	                 fire('websocket::connect', e);
	             });
        pusher.bind('pusher:connection_failed',
	             function(e){
	                 fire('websocket::error', e);
	             });

        var channel = pusher.subscribe('as:' + AsakusaSatellite.current.room );
        channel.bind('message_create',
                     function(obj){
                         console.log("create");
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
