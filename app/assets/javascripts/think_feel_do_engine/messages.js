(function() {
  function displayMessages() {
    $('#messages-tab a:first').tab('show');
  };

  $(document).ready(displayMessages);
  $(document).on('page:load', displayMessages);
})();