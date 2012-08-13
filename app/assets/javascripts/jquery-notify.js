(function($, document, undefined) {
    jQuery.fn.notify = function(config){
        var target = this;
        var config = jQuery.extend({
            _notify : jQuery.fn.desktopNotify
        }, config);
        target.bind('websocket::create',function(_, message){
            var attached =
                (message.attachment != null) && (message.attachment.length > 0);
            if(message.screen_name != config.current_user) {
                config._notify({
                    picture: message.profile_image_url,
                    title: message.name + " / " + message.room.name,
                    text : attached ? message.attachment.filename : message.body
                });
            }
        });
        return this;
    }
})(jQuery, document);
