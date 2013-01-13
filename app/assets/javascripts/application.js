//= require jquery-min
//= require rails
//= require_self
//= require "jquery-localstorage"

var AsakusaSatelliteUtil = {
    onMessageHover : function(dom) {
        dom.hover(function(e) {
            $(this).find('.edit-icons').fadeIn();
        },function(e){
            $(this).find('.edit-icons').fadeOut();
        });
    }
}

$(function(){
    AsakusaSatelliteUtil.onMessageHover($('.message'));
});
