(function($) {
    function log(msg){
	console && console.log && console.log(msg);
    }

    jQuery.fn.recvMessage = function(config){
	config = jQuery.extend({
	    entry : "ws://" + location.hostname + ":18081",
	    onCreate : function(){},
	    onStatus : function(b){
		$("img.connection-status").each(function(_,c){
		    c.src = b ?  config.success_icon : config.fail_icon;
		});
	    }
	},config);
	config.onStatus(false);

	var target = this;

	function makeMessage(message){
	    return "<div class='message' style='display:none' target='" + message.id + "'>" +
		"<p><img class='profile' src='" + message.profile_image_url + "'>" +
		"<span>" + message.name + "</span></p>" +
		"<p>" + message.body + "</p></div>"
	}

	function appendMessage(message) {
	    var dom = $(makeMessage(message));
	    target.append(dom);
	    dom.fadeIn();
	}

	var ws = new WebSocket(config.entry);
	ws.onopen = function() {
	    config.onStatus(true);
	}

	ws.onmessage = function(text){
	    eval("var message = " + text.data);
	    if(message.event == "create"){
		var c = message.content;
		config.onCreate(c);
		appendMessage(c);
	    }
	}
	ws.onerror = function(msg){
	    console.log(msg);
	    config.onStatus(false);
	}
    };

    jQuery.fn.sendMessage = function(config){
	config = jQuery.extend({
	    entry: '/api/v1/message',
	    input : "input.text"
	},config);
	var target = this;

	$(function() {
	    target.bind("submit",function(e){
		e.stopPropagation();
		e.preventDefault();

		var elem = $(config.input, e.target);
		var text = elem.val();
		elem.val("");

		jQuery.ajax({
		    type: 'POST',
		    url: config.entry,
		    data: {
			'room_id' : config.room_id,
			'message' : text
		    },
		    success: function(e) {

			log("message sent:" + e);
		    },
		    error : function(e){
			console.log(e);
			log("message error:" + e.statusText);
		    }
		});
	    });
	});
    };
})(jQuery);

