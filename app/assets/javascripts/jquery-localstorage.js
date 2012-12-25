/**
 * HTML5 local storaage wrapper
 */
(function($, document, undefined){
    $.extend({LocalStorage : {
        get : function(key, defaultValue) {
            try {
                return JSON.parse(localStorage[key]) || defaultValue;
            } catch(e) {
                return defaultValue;
            }
        },
        set : function(key, value) {
            return localStorage[key] = JSON.stringify(value);
        },
    }});
})(jQuery, document);
