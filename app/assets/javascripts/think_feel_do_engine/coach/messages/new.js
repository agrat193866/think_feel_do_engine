(function() {
  // add the Markdown for a link to the selection
  $(document).on("change", "#coach-message-link-selection", function(event) {
    var intialContent, path, title;

    title = $(event.target.selectedOptions).text();
    path = $(event.target.selectedOptions).val();
    if (path !== "") {
      intialContent = $("#message_body").val();
      return $("#message_body").val(intialContent + " [" + title + "](" + path + ")");
    }
  });
})();