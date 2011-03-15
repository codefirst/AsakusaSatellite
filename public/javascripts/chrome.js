(function($) {
    $(function(){
	if (window.chrome && window.chrome.app && window.chrome.app.isInstalled) {
	    var w = null;
	    $(".chrome-extension").bind("click",function(){
		console.log(w);
		if(w){
		    $.fn.desktopNotify({
			title: "AsakusaSatellite Extension",
			text : "Background notification is disabled"
		    });
		    w.close();
		    w = null;
		}else{
		    w = window.open("../chrome#0", "background", "background");
		}
	    });
	} else {
            $(".chrome-extension").hide();
	}
    });
})(jQuery);
