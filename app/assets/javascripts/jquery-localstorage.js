/**
* HTML5 local storaage wrapper
*/
(function($, document, undefined){
    $.extend({LocalStorage : {
        get : function(key) {
            return localStorage[key];
        },
        getOrElse : function(key, defaultvalue) {
            return localStorage[key] || defaultvalue;
        },
        set : function(key, value) {
            localStorage[key] = value;
        }
    }});
})(jQuery, document);
