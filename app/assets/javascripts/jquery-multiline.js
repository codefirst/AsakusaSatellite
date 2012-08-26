/**
 * textarea with multiline text.
 * Enter      : submit
 * Shift+Enter: new line
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * mulitilinize textarea
     * @pamam config ignored
     * @return this
     */
    $.fn.multiline = function(config){
        var defaults = {
        };

        config = $.extend(defaults, config);
        var target = this;
        target.keydown(function(e){
            if(e.keyCode == 13 && !e.shiftKey){
                e.stopPropagation();
                e.preventDefault();

                target.trigger('submit');
            }
        });
        return this;
    }
})(jQuery, document);

