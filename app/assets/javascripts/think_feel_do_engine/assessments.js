attach_assessment_event = function() {
  $("#new_assessment").submit(function (event) {
    var missing_answer = false;
    $("li.radio-question-group").each(function (index) {
      var current_question = parseInt(index) + 1;
      if (!$("input:radio[name='assessment[q" + current_question + "]']:checked").val()) {
        missing_answer = true;
      }
    });
    if (missing_answer && !confirm("You have not responded to all of the questions. Would you like to submit with missing responses? If yes, please hit OK, if you would like to answer the questions, please hit cancel.")) {
      event.preventDefault();
    }
  });
}