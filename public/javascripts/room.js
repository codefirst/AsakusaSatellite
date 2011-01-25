(function() {
    function log(msg){
	console && console.log && console.log(msg);
    }

    jQuery.fn.recvMessage = function(config){
	config = jQuery.extend({
	    entry : "ws://" + location.hostname + ":18081"
	},config);

	var target = this;

	function makeMessage(message){
	    return "<div class='message' target='" + message.id + "'>" +
		"<p><img src='" + message.profile_image_url + "'>" +
		"<span>" + message.name + "</span></p>" +
		"<p>" + message.body + "</p></div>"
	}

	function appendMessage(message) {
	    target.append(makeMessage(message))
	}

	var ws = new WebSocket(config.entry);
	ws.onopen = function() {
	    log("connected.");
	}


	ws.onmessage = function(text){
	    eval("var message = " + text.data);
	    if(message.event == "create"){
		var c = message.content;
		appendMessage(c);
	    }
	}
	ws.onerror = function(msg){
	    log("error: " + msg);
	}

    };

    jQuery.fn.sendMessage = function(config){
	config = jQuery.extend({
	    url: '/api/v1/message',
	    input : "input.text"
	},config);
	var target = this;

	$().ready(function() {
	    target.bind("submit",function(e){
		e.stopPropagation();
		e.preventDefault();

		var elem = $(config.input, e.target);
		var text = elem.val();
		elem.val("");

		jQuery.ajax({
		    type: 'POST',
		    url: config.url,
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

