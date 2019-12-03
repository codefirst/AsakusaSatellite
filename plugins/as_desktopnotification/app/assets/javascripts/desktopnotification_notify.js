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
        function check(param, default_value){
            if (param == undefined) {
                return default_value;
            } else {
                return param;
            }
        }

        var current = AsakusaSatellite.current;
        var allowed = $.LocalStorage.get('notification_setting_for_rooms', {})[current.room];
        return (current.user != message.screen_name) && check(allowed, true);
    }

    /**
     * display desktop notification.
     * @param {String} options.picture url of icon file
     * @param {String} options.title title string
     * @param {String} options.text notification message
     * @param {function} options.onclose function called on closed
     */
    function desktopNotify(options) {
        var defaults = {
            picture : "",
            title : "",
            text : "",
            onclose : onclose
        };

        var onclose = function() {};

        var setting = $.extend(defaults, options);
        if ($.DesktopNotification.isAvailable()) {
            var send = function() {
                var popup = $.DesktopNotification.createNotification(
                    setting.picture,
                    setting.title,
                    setting.text
                );
                popup.onclose = setting.onclose;

                var delay = $.LocalStorage.get('notificationTime', 3);
                if (delay > 0) {
                    setTimeout(function() {
                        if (popup.cancel) {
                            popup.cancel();
                        } else if (popup.close) {
                            popup.close();
                        }
                    }, delay * 1000);
                }
            }
            switch ($.DesktopNotification.checkPermission()) {
              case 0:
                // granted
                send();
                break;
              case 1:
                // default
                $.DesktopNotification.requestPermission(send);
                break;
              default:
                // denied
            }
        }
    };

    $(".message-list").setupDesktopNotify();
})(jQuery, document);

