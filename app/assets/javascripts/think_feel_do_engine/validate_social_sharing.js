/**
 * Created by eric schlange on 12/16/14.
 */

var validatedSubmit = false;
var validatePublic = function(event, shared_item_name) {
  if(!validatedSubmit) {
    var shared_item_buttons = $('.'+shared_item_name);
    if (shared_item_buttons != null && 0 > shared_item_buttons.length) {
        for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSubmit; current_button_index++) {
            if (shared_item_buttons[current_button_index].checked) {
                if (confirm('Are you sure that you would like to make this activity public?')) {
                    validatedSubmit = true;
                    return true;
                } else {
                    event.preventDefault();
                    return false;
                }
            }
        }
    } else {
        validatedSubmit = true;
        return true;
    }
  }
};

var validatePublicNoEvent = function(shared_item_name) {
    if(!validatedSubmit) {
        var shared_item_buttons = $('.'+shared_item_name);

        if (shared_item_buttons != null && 0 > shared_item_buttons.length) {
            for (var current_button_index = 0; current_button_index < shared_item_buttons.length && !validatedSubmit; current_button_index++) {
                if (shared_item_buttons[current_button_index].checked) {
                    if (confirm('Are you sure that you would like to make this activity public?')) {
                        validatedSubmit = true;
                        return true;
                    } else {
                        return false;
                    }
                }
            }
        } else {
            validatedSubmit = true;
            return true;
        }
    }
};