(function($) {
    jQuery.fn.multiline = function(config){
	var defaults = {
	    entry : 'ws://' + location.hostname + ':18081',
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
    }
})(jQuery);

