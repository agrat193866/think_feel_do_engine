(function() {
  $(document).on("change", "[name='thought[pattern_id]']:visible", renderDescription);

  function renderDescription(event) {
    var description = $(event.target.selectedOptions).data("description");
    if (description) {
      $(event.target).parent().siblings("#thought-pattern-description").html(description).show();
    } else {
      $(event.target).parent().siblings("#thought-pattern-description").html(description).hide();
    }
  }
})();
