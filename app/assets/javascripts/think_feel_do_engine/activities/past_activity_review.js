$(document).on('page:change', function() {
  var formEl = 'form.past-activity-review';

  $(document)
    .on('change', formEl + ' input[name="activity[is_complete]"]', function(event) {
      var val = $(event.target).val(),
          id = $(event.target).data('activityId');

      if (val === 'true') {
        $('#activity-incomplete-' + id).hide();
        $('#activity-complete-' + id).show();
      } else {
        $('#activity-complete-' + id).hide();
        $('#activity-incomplete-' + id).show();
      }

      $('#activity-submit-' + id).show();
    })
    .on('ajax:success', formEl, function(event, script, status, xhr) {
      $(this)
        .hide()
        .next(formEl).show();
      if ($(this).next(formEl).length === 0) {
        window.location.replace(window.location.origin + '/navigator/next_content');
      }
    });
});
