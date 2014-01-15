module("pagination module");

(function(){
    var target = $('<div />');
    var append = [];
    target.pagination({
        url     : 'http://example.com/api/v1/list',
        params  : function(){return {"room_id":"123", "older_than":"10"};},
        content : 'p',
        append  : function(elem){ append.push(elem); },
        current : function(){ return 10; }
    });

    var url = null;
    $.get = function(_url, f){
        append = [];
        ok(true);
        url = _url;
        f("<div><p>hello</p><p>world</p></div>");
    };

    test("clickすると次がロードされる",function(){
        target.trigger('click');
        equal(url, 'http://example.com/api/v1/list?room_id=123&older_than=10');
    });

    test("ロードが完了", function(){
        target.trigger('click');
        equal(append.length, 1);
    });

    test("ロード時にpagination::loadイベントが発生する",function(){
        stop(100);
        target.bind('pagination::load',function(_, elem){
            start();
            equal(elem.length, 1);
        });
        target.trigger('click');
    });
})();
