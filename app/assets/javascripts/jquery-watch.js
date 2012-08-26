/**
 * connect as::* events to other handlers
 * @author codefist
 */
(function($, document, undefined) {
    /**
     * fire function f to selected elements.
     * bind as::* events to f
     * @param {String} selector selector string
     * @param {function} f function to be fired.
     * @return this
     */
    $.fn.watch = function(selector, f){
        var target = this;

        target.find(selector).each(function(_, e){
            f($(e));
        });
        target.bind("as::append",function(_,elems){
            $(elems).filter(selector).each(function(_, e){
                f($(e));
            });
        });
        target.bind("as::prepend",function(_,elems){
            $(elems).filter(selector).each(function(_, e){
                f($(e));
            });
        });
        target.bind("as::before",function(_,elems){
            $(elems).filter(selector).each(function(_, e){
                f($(e));
            });
        });

        return this;
    }
})(jQuery, document);
