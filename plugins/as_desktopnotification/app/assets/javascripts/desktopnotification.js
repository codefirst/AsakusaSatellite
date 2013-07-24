(function($, document, undefined){
    var klass = {
        isAvailable : function() { return false; }
    };
    if(window.webkitNotifications) {
        var klass = {
            checkPermission : function(){
                return window.webkitNotifications.checkPermission();
            },
            requestPermission : function (cb) {
                return window.webkitNotifications.requestPermission(cb);
            },
            createNotification : function(picture, title, text) {
                var notification = window.webkitNotifications.createNotification(
                    picture,
                    title,
                    text
                );
                notification.show();
                return notification;
            },
            isAvailable : function() { return true; }
        };
    }
    if(window.Notification && window.Notification.permission){
        var permissionTable = {
            "granted" : 0,
            "default" : 1,
            "denied"  : 2
        };
        console.log(Notification.permission);
        var klass = {
            checkPermission : function(){
                return permissionTable[window.Notification.permission];
            },
            requestPermission : function (cb) {
                return window.Notification.requestPermission(cb);
            },
            createNotification : function(picture, title, text) {
                return new window.Notification(title, {
                    icon: picture,
                    body: text
                });
            },
            isAvailable : function() { return true; }
        };
    }
    $.extend({ DesktopNotification: klass });
})(jQuery, document);
