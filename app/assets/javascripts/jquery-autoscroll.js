//= require jquery-scrollTo

(function($, document, undefined){
    $.fn.autoscroll = function(selector, config) {
        var config = $.extend({
            scrollTo: function(e){
                $(window).scrollTo( e , 500, { easing:'swing', queue:true, axis:'y' } );
                $("img.attachment", e).bind("load", function(){
                    $(window).scrollTo( e , 500, { easing:'swing', queue:true, axis:'y' } );
                });
            }
        }, config);

        var target = this;

        var lasttarget = target.find(selector).last();
        if (lasttarget.length > 0) {
            config.scrollTo(lasttarget);
        }

        target.bind('as::append', function(_, elems){
            if( $(elems).filter(selector).length != 0){
                var last = target.find(selector).last();

                var newNodeTop = last[0].getBoundingClientRect().top;
                if( (newNodeTop - window.innerHeight) < 0 ){
                    config.scrollTo(last);
                }
            }
        });

        return { refresh : function(){
            config.scrollTo(target.find(selector).last());
        }};
    };
})(jQuery, document);
