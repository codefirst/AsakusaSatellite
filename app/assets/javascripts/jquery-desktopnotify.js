/**
 * jQuery plugin to use webkit Notifications
 * @author codefirst
 * @lisence MIT Lisence
 * @version 0.0.2
 */
//= require "jquery-localstorage"
(function($, document, undefined){
    /**
     * add event handler that check to have webkit notifications permission.
     * @param options ignored
     * @return this
     */
    $.fn.desktopNotifyAddPermission = function(options) {
        this.click(function(e) {
            if (window.webkitNotifications) {
                if (window.webkitNotifications.checkPermission()) {
                    window.webkitNotifications.requestPermission(function(){});
                }
            }
        });
        return this;
    };

    /**
     * fire a notification.
     * @param {String} options.picture url of icon file
     * @param {String} options.title title string
     * @param {String} options.text notification message
     * @param {function} options.ondisplay function called on diplayed
     * @param {function} options.onclose function called on closed
     * @return this
     */
    $.fn.desktopNotify = function(options) {
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

                var delay = $.LocalStorage.getOrElse('notificationTime', 3);
                if (delay > 0) {
                    setTimeout(function() {
                        popup.cancel();
                    }, delay*1000);
                }
            }
        }

        return this;
    };
})(jQuery, document);
