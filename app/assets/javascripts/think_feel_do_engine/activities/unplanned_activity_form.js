$(document).on('page:change', function() {
  var formEl = 'form.unplanned-activity-review';

  $(document)
    .on('ajax:success', formEl, function(event, script, status, xhr) {
      $(this)
        .hide()
        .next(formEl).show();
      if ($(this).next(formEl).length === 0) {
        completeFormWithSpinner();
      }
    });
});

function completeFormWithSpinner() {
  $('.tool-content').html('');
    $('.tool-content').append('<div class="spinner"><i class="fa fa-spinner fa-spin fa-4x form-spinner"></i></div>');
    setTimeout(function () {
      window.location.replace(window.location.origin + '/navigator/next_content');
  }, 600);
} 
