module("chat module");

(function(){
    var target = $('<div />');
    target.chat({
	make : function(m){
	    return $('<p message-id="' + m.id + '">' + m.body + '</p>');
	}
    });

    test("websocket::createの際にメッセージが追加される",function(){
	target.trigger('websocket::create', { "id" : 1, "body" : "hi" });
	equals($("p",target).length, 1);
	equals($("p",target).text(), 'hi');
    });

    test("websocket::updateの際にメッセージが更新される",function(){
	equals($("p",target).text(), "hi");
	target.trigger('websocket::update', { "id" : 1, "body" : "hello" });
	equals($("p",target).length, 1);
	equals($("p",target).text(), "hello");
    });

    test("websocket::deleteの際にメッセージが削除される",function(){
	target.trigger('websocket::delete', { "id" : 1 });
	stop(1000);
	setTimeout(function(){
	    start();
	    equals($("p",target).length, 0);
	},500);
    });
})();
