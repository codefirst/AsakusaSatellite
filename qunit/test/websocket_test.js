module("websocket module");

(function(){
    var target = $('<div />');

    var table = {};
    var MockPusher = {
        connection : {
            bind : function(name, f) {
                table[name] = f;
            }
        },
        subscribe : function(name){
            return {
                bind : function(name, f) {
                    table[name] = f;
                }
            }
        }
    };

    function fire(name, obj) {
        table[name](obj);
    }

    target.webSocket({ pusher  : MockPusher,
		       room    : 'test-room' });

    test('接続時にwebsocket::connectイベントが発生する' , function() {
	stop(500);
	target.bind('websocket::connect',function(){
	    start();
	    ok(true);
	});
        fire('connected');
    });

    test('接続時にwebsocket::errorイベントが発生する' , function() {
	stop(500);
	target.bind('websocket::error',function(_, msg){
	    start();
	    equal('msg', msg)
	});
        fire('failed', 'msg');
    });

    test('切断時にwebsocket::disconnectイベントが発生する' , function() {
	stop(500);
	target.bind('websocket::disconnect',function(){
	    start();
            ok(true);
	});
        fire('disconnected');
    });

    test('createメッセージ受信時にwebsokect::createイベントが発生する',function(){
	stop(500);
	target.bind('websocket::create',function(_, msg){
	    start();
	    equal('msg', msg)
	});
        fire('message_create',{
            'content' : 'msg'
        });
    });

    test('updateメッセージ受信時にwebsokect::updateイベントが発生する',function(){
	stop(500);
	target.bind('websocket::update',function(_, msg){
	    start();
	    equal('msg', msg)
	});
        fire('message_update',{
            'content' : 'msg'
        });
    });

    test('deleteメッセージ受信時にwebsokect::deleteイベントが発生する',function(){
	stop(500);
	target.bind('websocket::delete',function(_, msg){
	    start();
	    equal('msg', msg)
	});
        fire('message_delete', {
	    'content' : 'msg'
	});
    });
})();

