//= require "jquery-websocket"
//= require "jquery-chat"
//= require "jquery-pagination"
//= require "jquery-autoscroll"
//= require "jquery-watch"
//= require 'jquery-dropUploader'
//= require "jquery-multiline"
//= require "jquery-onthespot"
//= require "jquery-textcomplete"
//= require "jquery-replacestate"

$(function() {
    // on the spot
    function onTheSpot(dom){
        // You can edit your own message
        if (dom.find('.screen-name').text() == AsakusaSatellite.current.user) {
            dom.find(".own-message").show();
            var body = dom.find(".body");
            body.onTheSpot({
                url  : AsakusaSatellite.url.update + "/" + body.attr("id"),
                data : body.attr("original")
            });
            dom.find(".edit").bind("click",function(){ body.trigger("onTheSpot::start"); });
            dom.find(".delete").bind("click",function(){
                if(confirm(AsakusaSatellite.t['are_you_sure_you_want_to_delete_this_message'])){
                // http://travisonrails.com/2009/05/20/rails-delete-requests-with-jquery
                var id = dom.attr("message-id");
                    jQuery.ajax({
                        url: AsakusaSatellite.url.destroy + '/' + id,
                        type: 'delete',
                        success: function() { dom.remove(); },
                    });
                }
            });
        }else{
            dom.find(".own-message").hide();
        }

        AsakusaSatelliteUtil.onMessageHover(dom);
    }

    // ------------------------------
    // chat
    // ------------------------------
    var connected = false;
    $(".message-list")
    .webSocket({
        pusher : AsakusaSatellite.pusher,
        room   : AsakusaSatellite.current.room
    })
    .chat({
        make : function (message){ return $(message.view); }
    })
    .watch('div.message', function(elem){
        onTheSpot(elem);
    })
    .bind({
        'websocket::create' : function(){
            var audio = document.getElementById("audio");
            if(audio) {
                audio.load();
                audio.play();
            }
        },
        'websocket::connect' : function(){
            connected = true;
            $("img.websocket-status").attr('src', AsakusaSatellite.resouces.connect);
        },
        'websocket::error' : function(){
            connected = false;
            $("img.websocket-status").attr('src', AsakusaSatellite.resouces.disconnect);
        },
        'websocket::disconnect' : function(){
            connected = false;
            $("img.websocket-status").attr('src', AsakusaSatellite.resouces.disconnect);
        }
    });

    // ------------------------------
    // submit area
    // ------------------------------
    $('textarea#message').multiline();

    $('form.inputarea').bind('submit', function(e){
        var textcompleting = $(".dropdown-menu").is(":visible");

        if(connected && !textcompleting) {
            e.preventDefault();
            jQuery.post(AsakusaSatellite.url.create, {
                'room_id' : AsakusaSatellite.current.room,
                'message' : $('textarea#message').val()
            });
            $('textarea#message').val('');
        }
    });

    // ------------------------------
    // pagination
    // ------------------------------
    $("#read-more").pagination({
        current : function(){ return $(".message").first().attr("message-id"); },
        content : "div.message",
        append  : function(elem){ $(".message-list").prepend(elem); },
        url : AsakusaSatellite.url.prev,
        indicator : AsakusaSatellite.resouces.ajaxLoader
    });

    // ------------------------------
    // auto scroll
    // ------------------------------
    $(".message-list").autoscroll(".message");

    // ------------------------------
    // File DnD
    // ------------------------------
    document.body.addEventListener('dragenter', function(e){
        function isFileDrop(e){
            var type = e.dataTransfer.types;
            return (type[0] == "Files" ||               // chrome
                    type[3] == "Files" || type[4] == "Files" ||               // safari
                    type[0] == "application/x-moz-file" // firefox
                   );
        }

        if (AsakusaSatellite.current.user!="" && isFileDrop(e)) {
            $('.droppable').css({"display":"block"});
            setTimeout(function(){
                $('.droppable').css({"opacity":"1"});
            }, 0);
        }
    });

    $('.droppable').dropUploader({
        action : AsakusaSatellite.url.message,
        onDragover : function(e){
            e.preventDefault();
            e.stopPropagation();
        },
        onDragleave : function(e){
            $('.droppable').css({"opacity":"0"});
            setTimeout(function(){
                $('.droppable').css({"display":"none"});
            },200);
        },
        params : [{ room_id : AsakusaSatellite.current.room},
                  { authenticity_token: AsakusaSatellite.form_auth }
                 ]
    });
});

