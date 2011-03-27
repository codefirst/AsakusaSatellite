$.fn.__append = $.fn.append;
$.fn.append = function(){
    var ret = this.__append.apply(this, arguments);
    this.trigger("autoscroll::append", this);
    return ret;
};

(function($){
    $.fn.autoscroll = function(selector, config) {
	var config = jQuery.extend({
	    scrollTo: function(e){
		$(window).scrollTo( e , 500, { easing:'swing', queue:true, axis:'y' } );
		$("img", e).bind("load", function(){
		    $(window).scrollTo( e , 500, { easing:'swing', queue:true, axis:'y' } );
		});
	    }
	}, config);

        var target = this;

	config.scrollTo(target.find(selector).last());

	target.bind('autoscroll::append', function(){
	    var last = target.find(selector).last();
	    config.scrollTo(last);
	});

        return { refresh : function(){
	    config.scrollTo(target.find(selector).last());
	}};
     };
})(jQuery);
