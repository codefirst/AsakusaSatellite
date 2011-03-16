(function($){
    $.fn.member = function(config) {
        var defaults = {
        };
	var config = jQuery.extend(defaults, config);
        var target = this;

	target.bind("click", function(){
	    $.getJSON( config.url, function(content){
		target.trigger(content.member ? "member::join" : "member::leave", null);
	    });
	})
        return this;
    };
})(jQuery);
