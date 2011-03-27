module("multiline module");

(function(){
    test("enterがおされるとsubmitされる", function(){
	stop(500);
	var target = $('<form><textarea /></form>');
	var text   = target.find('textarea');
	text.multiline();
	target.bind('submit',function(){
	    start();
	    ok(true);
	});

	var e = new jQuery.Event('keydown');
	e.keyCode = 13;
	e.shiftKey = false;
	text.trigger(e);
    });

    test("shift+enterがおされるとsubmitされない", function(){
	var target = $('<form><textarea /></form>');
	var text   = target.find('textarea');
	text.multiline();
	target.bind('submit',function(){
	    ok(false);
	});

	var e = new jQuery.Event('keydown');
	e.keyCode = 13;
	e.shiftKey = true;
	text.trigger(e);
    });
})();
