/**
 * jQuery Plugin for HTML5 File API.
 */
(function($, document, undefined){
    /**
     * add event handler for File API.
     * @params {function} options.onDragstart function fired on dragstart (default: yes)
     * @params {function} options.onProgress function fired on progress (default: yes)
     * @params {function} options.onComplete function fired on complete
     * @params {function} options.onMouseover function fired on mouseover (default: yes)
     * @params {function} options.onMouseout function fired on mouseout (default: yes)
     * @params {function} options.onError function fired on error
     * @params {String} options.action action name in posting formdata (default: empty)
     * @params {String} options.fieldName file field name in posting formdata (default: file)
     * @params {String} options.mimetypeFieldName mime field name in posting formdata (default: mimetype)
     * @params {Hash} options.params other parameters in posting formdata
     * @return TODO
     */
    $.fn.dropUploader = function(options){
        var self       = this;
        var options    = options;

        /**
         * _onDragstart
         * @param {Object} elm
         */
        var _onDragstart = function(elm){
            if(typeof options['onDragstart'] === 'function'){
                options['onDragstart']();
            }
            else{
                $(elm).css({
                    "border" : "5px dotted #cccccc"
                });
            }
        }

        /**
         * _onMouseover
         * @param {Object} elm
         */
        var _onMouseover = function(elm){
            if(typeof options['onMouseover'] === 'function'){
                options['onMouseover']();
            }
            else{
                $(elm).css({
                    "border" : "5px dotted #cccccc"
                });
            }
        }

        /**
         * _onMouseout
         * @param {Object} elm
         */
        var _onMouseout = function(elm){
            if(typeof options['onMouseout'] === 'function'){
                options['onMouseout']();
            }
            else{
                $(elm).css({
                    "border" : ""
                });
            }
        }

        /**
         * _getAction
         * @param {string} action
         * @param {string} filename
         */
        var _getAction = function(action, filename){
            var url = '';
            if(action.indexOf('?') > -1){
                url = action + '&filename=' + encodeURIComponent(filename);
            }
            else{
                url = action + '?filename=' + encodeURIComponent(filename);
            }
            if(options['params']){
                for(var i = 0, n = options['params'].length; i < n; i++){
                    for(param in options['params'][i]){
                        url += '&' + encodeURIComponent(param) + '=' + encodeURIComponent(options['params'][i][param]);
                    }
                }
            }
            url += '&fileupload=1'
            return url;
        }
        var fieldName = (!options['fieldName'] ? 'file' : options['fieldName']);
        var mimetypeFieldName = (!options['mimetypeFieldName'] ? 'mimetype' : options['mimetypeFieldName']);

        var result = this.each(function(){
            var elm = this;
            if(window.addEventListener){
                //for only 2 browsers. this means Google Chrome and Firefox having File API
                if(navigator.userAgent.match("Chrome") || (navigator.userAgent.match("Firefox") && window.FileReader)){
                    //setDroppable(elm);
                }
                elm.addEventListener(
                    'dragstart',
                    function(e){
                        if (e.dataTransfer.files > 0) {
                            _onDragstart(this);
                        }
                        e.preventDefault();
                    },
                    false
                );
                elm.addEventListener(
                    'dragenter',
                    function(e){
                        _onMouseover(this);
                        e.preventDefault();
                    },
                    false
                );
                elm.addEventListener(
                    'dragover',
                    function(e){
                        _onMouseover(this);
                        e.preventDefault();
                    },
                    false
                );
                elm.addEventListener(
                    'dragout',
                    function(e){
                        _onMouseout(this);
                        e.preventDefault();
                    },
                    false
                );
                elm.addEventListener(
                    'drop',
                    function(e){
                        e.preventDefault();
                        var files    = e.dataTransfer.files;
                        var total    = 0;
                        var loaded   = 0;
                        var progress = 0;
                        var counter  = 0;
                        var xcounter = 0;
                        var response = [];
                        $(this).addClass('wait');
                        for(var i = 0; i < files.length; i++){
                            var xhr = new XMLHttpRequest();
                            total = total + files[i].size;
                            xhr.upload.onprogress = function(e){
                                loaded = loaded + e.loaded;
                                if(typeof options['onProgress'] === 'function'){
                                    options['onProgress']((loaded / total) * 100 + "%");
                                }
                            }
                            xhr.upload.onload = function(e){
                                counter++;
                                if(i === counter){// upload is finished
                                    if(typeof options['onComplete'] === 'function'){
                                        options['onComplete']();
                                    }
                                    $(this).removeClass('wait');
                                    if(typeof options['onProgress'] === 'function'){
                                        options['onProgress'](0);
                                    }
                                }
                                else{
                                }
                            }
                            var filename = files[i].name;
                            var action = _getAction(options['action'],
                                                    (files[i].fileName || files[i].name));
                            xhr.open('post', action);
                            xhr.onreadystatechange = function(e){
                                if(this instanceof XMLHttpRequest && this.readyState === 4){
                                    xcounter++;
                                    try{
                                        response.push(this.responseText);
                                        if(i === xcounter){// upload is finished
                                            $(this).removeClass('wait');
                                            if(typeof options['onProgress'] === 'function'){
                                                options['onProgress'](0);
                                            }
                                            options['onComplete'](response);
                                        }
                                        else{
                                        }
                                    }
                                    catch(e){
                                        if(typeof options['onError'] === 'function'){
                                            options['onError']();
                                        }
                                    }
                                }
                            }
                            var file = files[i];
                            var data = new FormData();
                            data.append(fieldName, file);
                            data.append(mimetypeFieldName, file.type);
                            xhr.send(data);
                        }
                        _onMouseout(this);
                    },
                    false
                );
            }
        });
        return result;
    }
})(jQuery, document);
