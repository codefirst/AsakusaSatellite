(function($) {
    jQuery.fn.webSocket = function(config){
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

        var channel = pusher.subscribe('asakusa-satellite');
        channel.bind('message_create',
                     function(obj){
                         if(AsakusaSatellite.current.room == obj.room){
                             fire('websocket::create', obj.content);
                         }
                     });

        channel.bind('message_update',
                     function(obj){
                         if(AsakusaSatellite.current.room == obj.room){
                             fire('websocket::update', obj.content);
                         }
                     });

        channel.bind('message_delete',
                     function(obj){
                         if(AsakusaSatellite.current.room == obj.room){
                             fire('websocket::delete', obj.content);
                         }
                     });
	return this;
    }
})(jQuery);
