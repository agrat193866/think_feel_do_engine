(function() {
  function sort() {
    $('#sortable-slides').sortable({
      axis: 'y',
      handle: '.handle',
      update: function() {
        $.post($(this).data('update-url'), $(this).sortable('serialize'));
      }
    });
  };

  $(document).ready(sort);
  $(document).on('page:load', sort);
})();
