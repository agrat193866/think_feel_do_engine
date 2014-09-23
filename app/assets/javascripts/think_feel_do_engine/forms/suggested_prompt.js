;(function() {
  $(document).on('page:change', function() {
    // look for form elements that are optional, but suggested and
    // visible on the page
    // warn participants with a prompt if these elements are left empty
    $('form').on('submit', function() {
      var $suggestedInputs = $(this).find('.suggested:visible');
      var emptyInputsPresent = $suggestedInputs.filter(function(i, el) {
        return $(el).val() === "";
      }).length > 0;

      var $suggestedRadioInputs = $(this).find('.suggested-radio:visible');
      emptyInputsPresent = emptyInputsPresent || $suggestedRadioInputs.filter(function(i, el) {
        return typeof $(el).find('input:radio:checked').val() === "undefined";
      }).length > 0;

      if (emptyInputsPresent && confirm('You have not completed this form, are you sure you want to continue?') === false) {
        return false;
      }
    });
  });
})();
