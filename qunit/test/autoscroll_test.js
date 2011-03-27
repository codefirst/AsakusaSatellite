module("autoscroll module");

(function(){
    var last = null;
    var target = $('<div><p>a</p><p>b</p></div>')
    var auto = target.autoscroll('p',
				 { scrollTo: function(e){ last = e; }});
    test("最初に最後までスクロールされる", function(){
	equal(last.text(), "b");
    });
    test("要素が追加されるとスクロールする", function(){
	target.append($('<p>c</p>'));
	equal(last.text(), "c");
    });
    test("強制的にスクロールできる", function(){
	last = null;
	auto.refresh();
	equal(last.text(), "c");
    });

})();
