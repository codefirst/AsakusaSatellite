(function($){
    $.fn.readMore = function(config) {
        var defaults = {
        };
	var config = jQuery.extend(defaults, config);
        var target = this;

	function activate(elem, f){
	    elem.one('click',function(){
		f($(this), function(){ activate(elem, f); });
	    });
	}

	var original = target.text();
	activate(target, function(elem, resume){
  	    var id = config.id();
	    target.addClass("loading").empty().html(config.indicator);
	    $.get( config.url + "?id="+id, function(content){
		var dom = $(content).find( config.content );
		elem.removeClass("loading");
		if( dom.length == 0){
		    elem.empty().html("no more message");
		} else {
		    // show loaded message
		    dom.hide();
		    if(config.append){
			$(config.container).append(dom);
		    }else{
			$(config.container).prepend(dom);
		    }
		    dom.fadeIn();

		    // restore buton status
		    elem.empty().html(original);
		    resume();
		}
	    });
	});
        return this;
    };
})(jQuery);
