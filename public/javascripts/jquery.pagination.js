(function($){
    $.fn.pagination = function(config) {
	var config = jQuery.extend({
	    indicator : "",
	    content : "div"
	}, config);
        var target = this;

	function activate(elem, f){
	    elem.one('click',function(){
		f($(this), function(){ activate(elem, f); });
	    });
	}

	var original = target.text();
	activate(target, function(elem, resume){
	    console.log('c');
	    target.addClass("loading").empty().html(config.indicator);
	    $.get( config.url + "?id=" + config.current(), function(content){
		var dom = $(content).find(config.content);
		elem.removeClass("loading");
		if(dom.length == 0){
		    elem.empty().html("no more message");
		} else {
		    target.trigger('pagination::load', [ dom ]);

		    dom.hide();
		    config.append(dom);
		    dom.fadeIn();

		    elem.empty().html(original);
		    resume();
		}
	    });
	});

        return this;
     };
})(jQuery);
