module("pagination module");

(function(){
    var target = $('<div />');
    var append = null;
    target.pagination({
	url     : 'http://example.com/page',
	content : 'p',
	append  : function(elem){ append = elem; },
	current : function(){ return 10; }
    });

    var url = null;
    $.get = function(_url, f){
	ok(true);
	url = _url;
	f("<div><p>hello</p><p>world</p></div>");
    };

    test("clickすると次がロードされる",function(){
	target.trigger('click');
	equal(url, 'http://example.com/page?id=10');
    });

    test("ロードが完了", function(){
	target.trigger('click');
	equal(append.length, 2);
    });

    test("ロード時にpagination::loadイベントが発生する",function(){
	stop(100);
	target.bind('pagination::load',function(_, elem){
	    start();
	    equal(elem.length, 2);
	});
	target.trigger('click');
    });
})();
