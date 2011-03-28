(function($) {
    jQuery.fn.watch = function(selector, f){
	var target = this;
	target.find(selector).each(function(_, e){
	    f($(e));
	});
	target.bind("as::append",function(_,elems){
	    $(elems).filter(selector).each(function(_, e){
		f($(e));
	    });
	});
	target.bind("as::prepend",function(_,elems){
	    $(elems).filter(selector).each(function(_, e){
		f($(e));
	    });
	});
	return this;
    }
})(jQuery);
