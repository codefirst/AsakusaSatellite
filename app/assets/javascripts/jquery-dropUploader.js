/**
 * jQuery Plugin for HTML5 File API.
 */
(function($, document, undefined){
    $.fn.dropUploader = function(options){
        var self       = this;
        var options    = options;

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
                elm.addEventListener(
                    'dragenter',
                    (options['onDragenter'] || function(){}),
                    options['bubbling']
                );
                elm.addEventListener(
                    'dragend',
                    (options['onDragend'] || function(){}),
                    options['bubbling']
                );
                elm.addEventListener(
                    'dragover',
                    (options['onDragover'] || function(){}),
                    options['bubbling']
                );
                elm.addEventListener(
                    'dragstart',
                    (options['onDragstart'] || function(){}),
                    options['bubbling']
                );
                elm.addEventListener(
                    'dragleave',
                    (options['onDragleave'] || function(){}),
                    options['bubbling']
                );
                elm.addEventListener(
                    'dragcancel',
                    (options['onDragcancel'] || function(){}),
                    options['bubbling']
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
                        options['onDragleave'](e);
                    },
                    options['bubbling']
                );
            }
        });
        return result;
    }
})(jQuery, document);
