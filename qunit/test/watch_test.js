module("watch module");

(function(){
    var target = $('<div><p>a</p><p>b</p></div>')
    var elem = [];
    var auto = target.watch('p',
			    function(e){ elem.push(e); });

    test("初期状態にあるやつに適用される", function(){
	equal(elem[0].text(), "a");
	equal(elem[1].text(), "b");
    });

    test("追加したやつに適用される", function(){
	elem = [];
	target.append($('<p>c</p>'));
	equal(elem[0].text(), 'c');
    });
})();
