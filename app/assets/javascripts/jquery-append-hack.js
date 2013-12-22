(function($, document, undefined) {

$.fn.__append = $.fn.append;
$.fn.append = function(){
    var ret = this.__append.apply(this, arguments);
    this.trigger("as::append", Array.prototype.slice.call(arguments));
    return ret;
};

$.fn.__prepend = $.fn.prepend;
$.fn.prepend = function(){
    var ret = this.__prepend.apply(this, arguments);
    this.trigger("as::prepend", Array.prototype.slice.call(arguments));
    return ret;
};

$.fn.__before = $.fn.before;
$.fn.before = function(value){
    var ret = this.__before.apply(this, arguments);
    value.trigger("as::before", Array.prototype.slice.call(arguments));
    return ret;
};

$.fn.__replaceWith = $.fn.replaceWith;
$.fn.replaceWith = function(value){
    var ret = this.__replaceWith.apply(this, arguments);
    value.trigger("as::replaceWith", Array.prototype.slice.call(arguments));
    return ret;
};

})(jQuery, document);
