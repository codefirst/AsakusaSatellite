//= require jquery-jeditable-mini

/**
 * a wrapper for jQuery jeditable plugin.
 * @author codefirst
 */
(function($, document, undefined) {
    /**
     * add event handler for editing.
     * @param {String} config.submit label for OK button
     * @param {String} config.cancel label for Cancel button
     * @param {String} config.tooltip label for Tooltip
     * @param {function} config.onerror function called on error
     * @param {Number} config.textarea.rows textarea rows
     * @param {Number} config.textarea.cols textarea columns
     * @param this
     */
    $.fn.onTheSpot = function(config){
        var defaults = {
            submit  : 'OK',
            cancel  : 'Cancel',
            tooltip : '',
            onerror : function (settings, original, xhr) {
                original.reset();
                console.log(xhr);
            },
            textarea : {
                rows: 5,
                cols: 40
            }
        };
        config = $.extend(defaults, config);

        var target = this;

        var options = {
            tooltip: config.tooltip,
            cancel:  config.cancel,
            submit:  config.submit,
            method: "PUT",
            name: "message",
            event: "onTheSpot::start",
            placeholder : '',
            style: "",
            onsubmit: function (settings, td) {
                $(td).find('button').attr('disabled', 'disabled');
            }
        };

        if (config.select) {
            options.type = 'select';
            if (config.select.data != null) {
                options.submitdata = {
                    'select_array': config.select.data
                }
            }
            if (load_url != null) {
                options.loadurl = config.select.loadurl;
            }
        } else if(config.textarea) {
            options.type = 'textarea';
            options.rows = config.textarea.rows;
            options.cols = config.textarea.cols;
        }
        options.data = config.data;
        target.editable( config.url, options);
        return this;
    }
})(jQuery, document);
