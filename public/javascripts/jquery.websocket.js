(function($) {
    jQuery.fn.webSocket = function(config){
	var defaults = {
	    entry : 'ws://' + location.hostname + ':18081',
	};
	config = jQuery.extend(defaults, config);

	var target = this;
	function fire(name, data){
	    target.trigger(name, data);
	}

	var ws = new WebSocket(config.entry);
	ws.onopen = function() {
	    fire('websocket::connect', ws);
	}
	ws.onmessage = function(text){
	    eval('var message = ' + text.data);
	    switch(message.event){
	    case 'create':
		var obj = message.content;
		fire('websocket::create', obj);
		break;
	    case 'update':
		var obj = message.content;
		fire('websocket::update', obj);
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
	}
    }
})(jQuery);
