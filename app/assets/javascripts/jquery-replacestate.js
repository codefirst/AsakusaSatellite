/**
 * update browser history before leaving the page
 * @author codefirst
 */
(function($, document, undefined) {
    if (window.history && window.history.replaceState) {
        $(window).unload(function(){
            var latest_id = $(".message:last").attr("message-id");
            window.history.replaceState(latest_id ,"", location.pathname+"?latest="+latest_id);
        });
    }
})(jQuery, document);

