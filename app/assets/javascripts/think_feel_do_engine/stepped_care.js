window.sc = {};

sc.displayErrors = function() {
  _.each($('.form-control'), function(field, index, list) {
    var $field = $(field);

    $field.closest(".form-group").removeClass("has-error");
    if ($field.val() === "") {
      $field.closest(".form-group").addClass("has-error");
    };
  });
};