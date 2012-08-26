/**
 * connect websocket::create event to DesktopNotification event.
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * connect websocket::create event to DesktopNotification event.
     * @param {function} config._notify desktop notification function (default: $.fn.desktopNotify)
     * @return this
     */
    $.fn.notify = function(config){
        var target = this;

        var config = $.extend({
            _notify : $.fn.desktopNotify
        }, config);

        target.bind('websocket::create',function(_, message){
            var attachment = message.attachment;
            var attached = (attachment != null) && (attachment.length > 0);
            if(message.screen_name != config.current_user) {
                config._notify({
                    picture: message.profile_image_url,
                    title: message.name + " / " + message.room.name,
                    text : attached ? (attachment.filename || attachment.name) : message.body
                });
            }
        });

        return this;
    }
})(jQuery, document);
