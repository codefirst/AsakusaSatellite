$(function() {
    // on the spot
    function onTheSpot(dom){
	// You can edit your own message
	if (dom.find('.screen-name').text() == AsakusaSatellite.current.user) {
            var body = dom.find(".body");
            body.onTheSpot({
		url  : AsakusaSatellite.url.update,
		data : body.attr("original")
            });
            dom.find(".edit").bind("click",function(){ body.trigger("onTheSpot::start"); });
            dom.find(".delete").bind("click",function(){
		if(confirm(AsakusaSatellite.t['are_you_sure_you_want_to_delete_this_message'])){
		    // http://travisonrails.com/2009/05/20/rails-delete-requests-with-jquery
		    var id = dom.attr("target");
		    jQuery.post(AsakusaSatellite.url.destroy,
				{ 'id' : id, _method: 'delete' });
		}
            });
	}else{
            dom.find(".own-message").hide();
	}

	// show edit button
	dom.hover(function(e) {
            $(this).find('.edit-icons').fadeIn();
	},function(e){
            $(this).find('.edit-icons').fadeOut();
	});
    }

    // ------------------------------
    // chat
    // ------------------------------
    $(".message-list")
	.webSocket({
            entry : AsakusaSatellite.url.websocket
	})
	.chat({
	    make : function (message){ return $(message.view); }
	})
	.watch('div.message', function(elem){
	    onTheSpot(elem);
	})
	.notify({
	    current_user : AsakusaSatellite.current.user
	})
	.bind({
	    'websokcet::create' : function(){
		document.getElementById("audio").load();
		document.getElementById("audio").play();
	    },
	    'websocket::connect' : function(){
		$("img.websocket-status").attr('src', AsakusaSatellite.resouces.connect);
	    },
	    'websocket::error' : function(){
		$("img.websocket-status").attr('src', AsakusaSatellite.resouces.disconnect);
	    }
	});

    // ------------------------------
    // submit area
    // ------------------------------
    $('textarea#message').multiline();

    $('form.inputarea').bind('submit', function(e){
	e.preventDefault();
	jQuery.post(AsakusaSatellite.url.create, {
	    'room_id' : AsakusaSatellite.current.room,
	    'message' : $('textarea#message').val()
	});
	$('textarea#message').val('');
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
    uploadConfig = {
	action : AsakusaSatellite.url.message,
	params : [{ room_id : AsakusaSatellite.current.room},
		  { authenticity_token: AsakusaSatellite.form_auth }]
    };
    $('.message-list').dropUploader(uploadConfig);
    $('#message').dropUploader(uploadConfig);
});


