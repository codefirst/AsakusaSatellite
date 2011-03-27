$.fn.__append = $.fn.append;
$.fn.append = function(){
    var ret = this.__append.apply(this, arguments);
    this.trigger("as::append", this);
    return ret;
};