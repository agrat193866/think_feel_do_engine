(function() {
  $(document).on('page:change patient:rendered', function() {
    $('#patients .datepicker').each(function() {
      $(this).datepicker({
        dateFormat: 'M d, yy',
        altField: $(this).prev(),
        altFormat: 'yy-mm-dd',
        showButtonPanel: true
      });

      $(this).on('change', function() {
        $(this).closest('form').submit();
      });
    });
  });
})();
