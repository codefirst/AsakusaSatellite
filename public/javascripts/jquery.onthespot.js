(function($) {
    jQuery.fn.onTheSpot = function(config){
	var defaults = {
	    submit  : 'OK',
	    cancel  : 'Cancel',
	    tooltip : 'click here...',
	    onerror : function (settings, original, xhr) {
                original.reset();
                console.log(xhr);
	    },
	    textarea : {
		rows: 5,
		cols: 40
	    }
	};
	config = jQuery.extend(defaults, config);

	var target = this;

	target.mouseover(function() {
            $(this).css('background-color', '#EEF2A0');
	});
	target.mouseout(function() {
            $(this).css('background-color', 'inherit');
	});

        var options = {
	    tooltip: config.tooltip,
	    cancel:  config.cancel,
	    submit:  config.submit
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
    }
})(jQuery);
