/**
 * Created by eric schlange on 12/16/14.
 */
var validatePublic = function(event, shared_item_name) {
  // check if social sharing is included
  if ($('.'+shared_item_name).length > 0 && $('.'+shared_item_name+':checked').length > 0) {
    if (confirm('Are you sure that you would like to make these public?')) {
      return true;
    }
    else {
      event.preventDefault();
      return false;
    }
  } 
  // no social sharing
  else {
    return true;
  }
};

var validateMutliFormPage = function(event, shared_item_name, activity_id) {
  var shared_item_buttons = $("#activity-"+activity_id+" ."+shared_item_name);
  if (shared_item_buttons != null && 0 < shared_item_buttons.length) {
    for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSocialSubmit; current_button_index++) {
      if (shared_item_buttons[current_button_index].checked) {
        if (confirm('Are you sure that you would like to make this activity public?')) {
          return true;
        } else {
          event.preventDefault();
          return false;
        }
      }
    }
  } else {
    return true;
  }
}

var validatePublicNoEvent = function(event, shared_item_name) {
  if ($('.'+shared_item_name).length > 0 && $('.'+shared_item_name+':checked').length > 0) {
    if (confirm('Are you sure that you would like to make these public?')) {
      return true;
    }
    else {
      event.preventDefault();
      return false;
    }
  } 
  else {
    return true;
  }
};
