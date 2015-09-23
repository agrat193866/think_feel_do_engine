;(function() {
  "use strict";

  // Report actions associated with task statuses
  $(document).on("page:change", function() {
\    $("a.task-status").not(".disabled").on("click", function(event) {
      var $target, $taskStatusId;
      
      $target = $(event.currentTarget);
      $taskStatusId = $target.data("task-status-id");
      $.ajax({
        dataType: "script",
        type: "PUT",
        url: "/participants/task_status/" + $taskStatusId
      });
    });
  });
})();
