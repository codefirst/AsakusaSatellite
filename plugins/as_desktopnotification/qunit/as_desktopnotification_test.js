module("notify module");

(function(){
    AsakusaSatellite.current = {user : 'nzp', room : 'some room'};
    $.LocalStorage = { get : function(){return {"some room":true};} };
    window.webkitNotifications.checkPermission = function(){return 0;};
    window.webkitNotifications.createNotification = function(picture,title,text){
        obj = {};
        obj.picture = picture;
        obj.title = title;
        obj.text = text;
        return { show : function(){} };
    };

    var target = $('<div />');
    target.setupDesktopNotify();
    var obj = null;

    var mzp_message = {
	    name : 'mzpi',
	    screen_name : 'mzp',
	    body : 'hi',
	    room : { name : 'some room' },
	    profile_image_url : 'foo.png'
    };
    var nzp_message = {
	    name : 'nzp',
	    screen_name : 'nzp',
	    body : 'hi',
        room : { name : 'some room' },
	    profile_image_url : 'foo.png'
    };

    test("notify された内容が正しい", function(){
        target.trigger('websocket::create', mzp_message);
        
	    equal(obj.picture, "foo.png", "notify された内容が正しい(picture)");
	    equal(obj.title, "mzpi / some room", "notify された内容が正しい(title)");
	    equal(obj.text, 'hi', "notify された内容が正しい(text)");
        expect(3);
    });

    test('自分の発言はnotifyされない', function(){
	    obj = null;
	    target.trigger('websocket::create', nzp_message);
        equal(obj, null, '自分の発言はnotifyされない');
    });

    test('通知を許可していない部屋ではnotifyされない', function(){
        obj = null;
        $.LocalStorage = { get : function(){return {"some room":false};} };

        target.trigger('websocket::create', mzp_message);
        equal(obj, null, '通知を許可していない部屋ではnotifyされない');
    });

    test('通知を許可していない場合はnotifyされない', function(){
        obj = null;
        $.LocalStorage = { get : function(){return {"some room":true};} };
        window.webkitNotifications.checkPermission = function(){return 1;};

        target.trigger('websocket::create', nzp_message);
        equal(obj, null, '通知を許可していない場合はnotifyされない');
    });
})();
