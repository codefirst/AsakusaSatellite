module("notify module");

(function(){
    var target = $('<div />');
    var obj = null;
    target.notify({
	current_user : 'nzp',
	_notify : function(_obj){ obj = _obj; },
    });
    target.trigger('websocket::create', {
	name : 'mzpi',
	screen_name : 'mzp',
	body : 'hi',
	room : { name : 'some room' },
	profile_image_url : 'foo.png'
    });

    test("pictureはprofile_image_url", function(){
	equal(obj.picture, "foo.png");
    });

    test("titleは'発言者 / 部屋名'", function(){
	equal(obj.title, "mzpi / some room");
    });

    test("textは本文", function(){
	equal(obj.text, 'hi');
    });

    test('自分の発言はnotifyされない', function(){
	obj = null;
	target.trigger('websocket::create', {
	    name : 'nzp',
	    screen_name : 'nzp',
	    body : 'hi',
	    profile_image_url : 'foo.png'
	});
    });
})();
