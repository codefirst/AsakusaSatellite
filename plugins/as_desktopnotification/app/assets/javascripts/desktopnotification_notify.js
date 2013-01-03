/**
 * jQuery plugin to use webkit Notifications
 * @author codefirst
 * @lisence MIT Lisence
 * @version 0.0.2
 */
(function($, document, undefined){
    /**
     * connect websocket::create event to DesktopNotification event.
     * @return this
     */
    $.fn.setupDesktopNotify = function(){
        var target = this;
        
        target.bind('websocket::create',function(_, message){
            var attachment = message.attachment;
            var attached = (attachment != null) && (attachment.length > 0);
            if(isAllowedToNotify(message)) {
                desktopNotify({
                    picture: message.profile_image_url,
                    title: message.name + " / " + message.room.name,
                    text : attached ? (attachment[0].filename || attachment[0].name) : message.body
                });
            }
        });
    };
    
    /**
     * check if desktop notify is enabled
     * @param message to check
     */
    function isAllowedToNotify(message){
        var current = AsakusaSatellite.current;
        return (current.user != message.screen_name) &&
            $.LocalStorage.get('notification_setting_for_rooms', {})[current.room];
    }
    
    /**
     * display desktop notification.
     * @param {String} options.picture url of icon file
     * @param {String} options.title title string
     * @param {String} options.text notification message
     * @param {function} options.ondisplay function called on diplayed
     * @param {function} options.onclose function called on closed
     */
    function desktopNotify(options) {
        var defaults = {
            picture : "",
            title : "",
            text : "",
            ondisplay : ondisplay,
            onclose : onclose
        };
        
        var ondisplay = function() {};
        var onclose = function() {};
        
        var setting = $.extend(defaults, options);
        if (window.webkitNotifications) {
            if (!window.webkitNotifications.checkPermission()) {
                var popup = window.webkitNotifications.createNotification(
                    setting.picture,
                    setting.title,
                    setting.text
                );
                popup.ondisplay = setting.ondisplay;
                popup.onclose = setting.onclose;
                popup.show();
                
                var delay = $.LocalStorage.get('notificationTime', 3);
                if (delay > 0) {
                    setTimeout(function() {
                        popup.cancel();
                    }, delay*1000);
                }
            }
        }
    };
})(jQuery, document);
(function(){
    $(".message-list").setupDesktopNotify();
})();
