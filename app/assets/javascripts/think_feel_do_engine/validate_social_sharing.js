/**
 * Created by eric schlange on 12/16/14.
 */
var validatedSocialSubmit = false;
var validatePublic = function(event, shared_item_name) {
  if(!validatedSocialSubmit) {
    var shared_item_buttons = $('.'+shared_item_name);
    if (shared_item_buttons != null && 0 < shared_item_buttons.length) {
      for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSocialSubmit; current_button_index++) {
        if (shared_item_buttons[current_button_index].checked) {
          if (confirm('Are you sure that you would like to make this activity public?')) {
            validatedSocialSubmit = true;
            return true;
          } else {
            event.preventDefault();
            return false;
          }
        }
      }
    } else {
        validatedSocialSubmit = true;
        return true;
    }
  }
};

var validateMutliFormPage = function(event, shared_item_name, activity_id) {
  validatedSocialSubmit = false;
  if(!validatedSocialSubmit) {
    var shared_item_buttons = $("#activity-"+activity_id+" ."+shared_item_name);
    if (shared_item_buttons != null && 0 < shared_item_buttons.length) {
      for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSocialSubmit; current_button_index++) {
        if (shared_item_buttons[current_button_index].checked) {
          if (confirm('Are you sure that you would like to make this activity public?')) {
            validatedSocialSubmit = true;
            return true;
          } else {
            event.preventDefault();
            return false;
          }
        }
      }
    } else {
      validatedSocialSubmit = true;
      return true;
    }
  }
}

var validatePublicNoEvent = function(event, shared_item_name) {
  if(!validatedSocialSubmit) {
    var shared_item_buttons = $('.'+shared_item_name);
    if (null != shared_item_buttons && 0 < shared_item_buttons.length) {
      for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSocialSubmit; current_button_index++) {
        if (shared_item_buttons[current_button_index].checked) {
          if (confirm('Are you sure that you would like to make this activity public?')) {
            validatedSocialSubmit = true;
            return true;
          } else {
            event.preventDefault();
            return false;
          }
        }
      }
    } else {
      validatedSocialSubmit = true;
      return true;
    }
  }
};
