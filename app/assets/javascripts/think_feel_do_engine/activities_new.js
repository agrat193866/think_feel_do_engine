$(document).on('page:change', function() {
  $(document)
    .on('ajax:success', 'form.activity_form', function(event, script, status, xhr) {
      $(this).hide();
      $(this).next('form.activity_form').show();
      if (!$("form.activity_form").is(":visible")) {
        window.location.replace(window.location.origin+"/navigator/next_content")
      };
    })
    .on('ajax:error', 'form.activity_form', function(event, xhr, status) {
      if ($('#alerts').text().trim() === '') {
        $('#alerts').html('<i class="fa fa-flag text-danger"></i> There was a problem, please try again');
      }
    });
});
