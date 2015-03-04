;(function() {
  'use strict';

  $(document).on('ready, page:change', function() {
    addNewActivityFormListener();
    addUnplannedActivityFormListener();
    addPastActivityReviewFormListener();
  });

  function addNewActivityFormListener() {
    $(document)
      .on('ajax:success', 'form.activity_form', function(event, script, status, xhr) {
        $(this).hide();
        $(this).next('form.activity_form').show();
        if (!$("form.activity_form").is(":visible")) {
          window.location.replace(window.location.origin+"/navigator/next_content");
        }
      })
      .on('ajax:error', 'form.activity_form', function(event, xhr, status) {
        if ($('#alerts').text().trim() === '') {
          $('#alerts').html('<i class="fa fa-flag text-danger"></i> There was a problem, please try again');
        }
      });
  }

  function addUnplannedActivityFormListener() {
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
  }

  function completeFormWithSpinner() {
    $('.tool-content').html('');
      $('.tool-content').append('<div class="spinner"><i class="fa fa-spinner fa-spin fa-4x form-spinner"></i></div>');
      setTimeout(function () {
        window.location.replace(window.location.origin + '/navigator/next_content');
    }, 600);
  } 

  function addPastActivityReviewFormListener() {
    var formEl = 'form.past-activity-review';

    $(document)
      .on('change', formEl + ' input[name="activity[is_complete]"]', function(event) {
        var val = $(event.target).val(),
            id = $(event.target).data('activityId');

        if (val === 'true') {
          $('#activity-incomplete-' + id).hide();
          $('#activity-complete-' + id)
          .show()
          .find('select#activity_actual_accomplishment_intensity, select#activity_actual_pleasure_intensity')
            .removeAttr("disabled")
        } else {
          $('#activity-complete-' + id)
          .hide()
          .find('select#activity_actual_accomplishment_intensity, select#activity_actual_pleasure_intensity')
            .attr("disabled", "disabled");
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
  }
})();
