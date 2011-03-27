module("websocket module");

(function(){
    var target = $('<div />');
    var mock = null;
    function MockWs(url) {
	this.url = url;
	mock = this;
	return this;
    }
    MockWs.prototype.fire = function(name, arg){
	this[name](arg);
    };
    target.webSocket({ _class : MockWs,
		       entry : 'ws://example.com' });

    test('entryでURLにアクセスする', function() {
	equal(mock.url, 'ws://example.com');
    });

    test('接続時にwebsocket::connectイベントが発生する' , function() {
	stop(500);
	target.bind('websocket::connect',function(){
	    start();
	    ok(true);
	});
	mock.onopen();
    });

    test('接続時にwebsocket::errorイベントが発生する' , function() {
	stop(500);
	target.bind('websocket::error',function(_, msg){
	    start();
	    equal('msg', msg)
	});
	mock.onerror('msg');
    });

    test('createメッセージ受信時にwebsokect::createイベントが発生する',function(){
	stop(500);
	target.bind('websocket::create',function(_, msg){
	    start();
	    equal('msg', msg)
	});
	mock.onmessage({
	    data : '{ "event" : "create", "content" : "msg" }'
	});
    });

    test('updateメッセージ受信時にwebsokect::updateイベントが発生する',function(){
	stop(500);
	target.bind('websocket::update',function(_, msg){
	    start();
	    equal('msg', msg)
	});
	mock.onmessage({
	    data : '{ "event" : "update", "content" : "msg" }'
	});
    });

    test('deleteメッセージ受信時にwebsokect::deleteイベントが発生する',function(){
	stop(500);
	target.bind('websocket::delete',function(_, msg){
	    start();
	    equal('msg', msg)
	});
	mock.onmessage({
	    data : '{ "event" : "delete", "content" : "msg" }'
	});
    });
})();