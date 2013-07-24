/**
 * jQuery plugin to use webkit Notifications
 * @author codefirst
 * @lisence MIT Lisence
 * @version 0.0.2
 */
(function($, document, undefined){
    /**
     * add event handler that check to have webkit notifications permission.
     * @param callback called after taking permission
     * @param options ignored
     * @return this
     */
    $.fn.desktopNotifyAddPermission = function(callback, options) {
        this.click(function(e) {
            e.preventDefault();
            if ($.DesktopNotification.isAvailable()) {
                if ($.DesktopNotification.checkPermission()) {
                    $.DesktopNotification.requestPermission(callback);
                }
            }
        });
        return this;
    };
})(jQuery, document);

$(function() {
    var PermissionAllowed = 0;
    var PermissionNotAllowed = 1;
    var PermissionDenied = 2;
    
    var action = [];
    action[PermissionAllowed] = function(){
        $('#dn-button').attr("disabled", "disabled").addClass("gray");
        $('.rooms').css("display", "block");
    };
    action[PermissionNotAllowed] = function(){
        $('#dn-button').desktopNotifyAddPermission(function(){
            action[$.DesktopNotification.checkPermission()]();
        });
    };
    action[PermissionDenied] = function(){
        $('#dn-button').attr("disabled", "disabled").addClass("gray").val("Permission denied by your browser");
    };
    if ($.DesktopNotification.isAvailable()){
        action[$.DesktopNotification.checkPermission()]();
    }
});
$(function() {
    $('#notification-time').val($.LocalStorage.get('notificationTime', 3));
    $('#set-notification-time-button').bind('click', function(e){
        var time = parseInt($('#notification-time').val());
        if (!isNaN(time)) {
            $.LocalStorage.set('notificationTime', time);
        }
    });
});
$(function() {
    function check(param, default_value){
        if (param == undefined) {
            return default_value;
        } else {
            return param;
        }
    }
    var KEY = 'notification_setting_for_rooms';
    
    $("#as_notification_setting .rooms input").click(function(e){
        e.preventDefault();
        
        var roomName = this.name;
        var setting = $.LocalStorage.get(KEY, {});
        setting[roomName] = !check(setting[roomName], true);
        $.LocalStorage.set(KEY, setting);
        
        $(this).toggleClass("gray").val( setting[roomName] ? "Notification On" : "Notification Off" );
    }).map(function(idx, button){
        var allowed = $.LocalStorage.get(KEY, {})[button.name];
        if (check(allowed, true)) {
            $(button).addClass('gray').val("Notification On");
        } else {
            $(button).removeClass('gray').val("Notification Off");
        }
    });
});
