(function() {

window.sc = window.sc || {};

sc.displayErrors = function() {
  _.each($('.form-group, .input-group'), function(field, index, list) {
    var $field = $(field);

    $field.removeClass('has-error');
    if (!(sc.validInputGroupAddon($field)
      && sc.validInputGroupBtn($field)
      && sc.validSelect($field))) {
      $field.addClass('has-error');
    }
  });
  sc.validateAtLeastOneActivityIsSelected();
};

sc.validateAtLeastOneActivityIsSelected = function() {
  if ($('input.choose-one:checked').length === 0) {
    $('#alerts')
      .html('<div class="alert alert-danger">Select at least one activity.</div>');
    $('input.choose-one')
      .closest('.input-group')
      .addClass('has-error');
  } else {
    $('.alert-danger').remove();
  }
};

sc.validInputGroupAddon = function($field) {
  var PARTS_OF_AN_INPUT_GROUP_ADDON;

  PARTS_OF_AN_INPUT_GROUP_ADDON = 2;
  if ($field.find('input[type=\'radio\'], input[type=\'checkbox\'], input[type=\'text\']').length === PARTS_OF_AN_INPUT_GROUP_ADDON) {
    return $field.find('input:checked').length === 0
    || $field.find('input.form-control').val() !== '';
  } else {
    return true;
  }
};

sc.validInputGroupBtn = function($field) {
  return $field.find('span.input-group-btn').length === 0
  || $field.find('input[type=\'text\']').val() !== '';
};

sc.validSelect = function($field) {
  return $field.find('select').length === 0
  || $field.find('select option:selected').val() !== '';
};

})();