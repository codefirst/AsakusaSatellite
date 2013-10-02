/**
 * update browser history before leaving the page
 * @author codefirst
 */
(function($, document, undefined) {
    if (window.history && window.history.replaceState) {
        $(window).on("unload", function(){
            var latestId = $(".message:last").attr("message-id");
            window.history.replaceState(latestId ,"", location.pathname+"?latest="+latestId);
        });
    }
})(jQuery, document);

