var config = {
    entry : "ws://" + location.hostname + ":18081"
}

function log(msg){
    console && console.log && console.log(msg);
    $("div.status").html(msg);
}

function makeMessage(message){
    return "<div class='message' target='" + message.id + "'>" +
        "<p><img src='" + message.profile_image_url + "'>" +
	"<span>" + message.name + "</span></p>" +
	"<p>" + message.body + "</p></div>"
}

function appendMessage(message){
    $(".message-list").append(makeMessage(message))
}

ws = new WebSocket(config.entry);
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

$(document).ready(function() {
    $("form").bind("submit",function(e){
	e.stopPropagation();
	e.preventDefault();

	var text = $("input.text", e.target).val();

	jQuery.ajax({
	    type: 'POST',
	    url: '/api/v1/message',
	    data: {
		'room_id' : Global.room_id,
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
