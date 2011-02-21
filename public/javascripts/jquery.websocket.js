(function($) {
    jQuery.fn.webSocket = function(config){
	var defaults = {
	    entry : 'ws://' + location.hostname + ':18081/',
	};
	config = jQuery.extend(defaults, config);

	var target = this;
	function fire(name, data){
	    target.trigger(name, data);
	}

	var ws = new WebSocket(config.entry + "?room="+config.room);
	ws.onopen = function() {
	    fire('websocket::connect', ws);
	}
	ws.onmessage = function(text){
	    eval('var message = ' + text.data);
	    var obj = message.content;
	    switch(message.event){
	    case 'create':
		fire('websocket::create', obj);
		break;
	    case 'update':
		fire('websocket::update', obj);
	    case 'delete':
		fire('websocket::delete', obj);
		break;
	    }
	}
	ws.onerror = function(msg){
	    fire('websocket::error', msg);
	}
	if(config.makeElement){
	    target.bind('websocket::create', function(_, obj) {
		var dom = $( config.makeElement(obj) );
		dom.hide();
		target.append(dom);
		dom.fadeIn();
	    });

	    target.bind('websocket::update', function(_, obj) {
		var dom = $( config.makeElement(obj) );
		dom.hide();
		$("[target=" + obj.id + "]").replaceWith(dom);
		dom.fadeIn();
	    });

	    target.bind('websocket::delete', function(_, obj){
		var dom = $("[target=" + obj.id + "]");
		dom.fadeOut(function(){ dom.remove(); });
	    });
	}
    }
})(jQuery);
