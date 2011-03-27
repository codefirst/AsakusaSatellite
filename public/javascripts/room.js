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
    var chatArea = $(".message-list");
    function makeElement(message){
	var dom = $(message.view);
	onTheSpot(dom);
	return dom;
    }

    chatArea.webSocket({
        entry : AsakusaSatellite.url.websocket
    });
    chatArea.chat({
	make : makeElement
    });

    // ------------------------------
    // submit area
    // ------------------------------
    $('textarea#message').multiline();

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
    $("#read-more").bind("pagination::load",function(_, messages){
	messages.each(function(_, e){ onTheSpot($(e)); });
    });

    // ------------------------------
    // auto scroll
    // ------------------------------
    $(".message-list").autoscroll(".message");

    // ------------------------------
    $(".message").each(function(_, e){
	onTheSpot( $(e) );
    });

    // messages send
    $(".message-list").bind('websocket::connect', function(_, ws){
	$('form.inputarea').bind('submit', function(e){
	    e.stopPropagation();
	    e.preventDefault();
	    jQuery.post(AsakusaSatellite.url.create,
			{
			    'room_id' : AsakusaSatellite.current.room,
			    'message' : $('textarea#message').val()
			});
	    $('textarea#message').val('');
	});
    });

    // show status of websocket
    $(".message-list").bind('websocket::connect', function(){
	$("img.websocket-status").attr('src', AsakusaSatellite.resouces.connect);
    });
    $(".message-list").bind('websocket::error', function(){
	$("img.websocket-status").attr('src', AsakusaSatellite.resouces.disconnect);
    });

    // message notification
    $(".message-list").bind('websocket::create', function(_, message){
	if(message.screen_name != AsakusaSatellite.current.user) {
	    $.fn.desktopNotify({
		picture: message.profile_image_url,
		title: message.name + " / " + message.room.name,
		text : (message.attachment != null ? message.attachment.filename : message.body)
	    });
	}
	document.getElementById("audio").load();
	document.getElementById("audio").play();
    });

    // File DnD
    uploadConfig = {
	action : AsakusaSatellite.url.message,
	params : [{ room_id : AsakusaSatellite.current.room},
		  { authenticity_token: AsakusaSatellite.form_auth }],
	onProgress : function(value){
	    console.log(value);
	},
	onPartialError : function(){
	},
	onComplete : function(){
	}
    };
    $('.message-list').dropUploader(uploadConfig);
    $('#message').dropUploader(uploadConfig);
});


