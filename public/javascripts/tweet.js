function loadTweets(){
    var elem = $('#tweets');
    elem.html("");
    $.getJSON('/tweets.json', function(tweets){
	$.each(tweets, function(_, t){
	    elem.append('<div class="tweet">'+t.content+'</div>');
	});
    });
}

WS_URL = "ws://localhost:8080";

ws = new WebSocket(WS_URL);
ws.onopen = function() {
    console.log("connected.");
}

ws.onmessage = function(){
    loadTweets();
}

ws.onerror = function(msg){
    console.log(msg);
}

$(document).ready(function() {
    loadTweets();

    $("form.tweet").bind("submit",function(e){
	e.stopPropagation();
	e.preventDefault();

	var e    = $("input[name=content]", e.target);
	var text = e.val();

	console.log("send:" + text);
	ws.send(text);

	e.val("");
    });
});