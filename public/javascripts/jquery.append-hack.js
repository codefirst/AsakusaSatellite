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