;(function() {
  "use strict";

  // Report actions associated with task statuses
  $(document).on("ready, page:change", function() {
    $("a.task-status").on("click", function(event) {
      var $target, taskStatusId;
      $target = $(event.currentTarget);
      taskStatusId = $target.data("task-status-id");
      $.ajax({
        async: false,
        dataType: "script",
        type: "PUT",
        url: "/participants/task_status/" + taskStatusId
      });
    });
  });
})();
