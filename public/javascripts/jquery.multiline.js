(function($) {
    jQuery.fn.multiline = function(config){
	var defaults = {
	};

	config = jQuery.extend(defaults, config);
	var target = this;
	target.keydown(function(e){
	    if(e.keyCode == 13 && !e.shiftKey){
		e.stopPropagation();
		e.preventDefault();

		target.trigger('submit');
	    }
	});
	return this;
    }
})(jQuery);

