$(document).on("page:change", function() {
  var forms;
  $("form.edit-emotion-form .checkbox input").on("change", function(event) {
    var form, target;
    target = $(event.currentTarget);
    form = $(target).closest("form.edit-emotion-form");
    return form.find(".intensity-scale").toggle();
  });
  return $("#update-emotions").on("click", function(event) {
    var $target, numberOfForms;
    event.preventDefault();
    forms = $("form input:checked").closest("form");
    numberOfForms = forms.length;
    $target = $(event.currentTarget);
    $.each(forms, function(index, form) {
      var data;
      data = $(form).serialize();
      return $.ajax({
        type: $(form).attr("method"),
        url: $(form).attr("action"),
        data: data,
        dataType: "script",
        success: function(response) {
          numberOfForms = numberOfForms - 1;
          if (numberOfForms === 0) {
            return window.location.href = $target.attr("href");
          }
        }
      });
    });
    return false;
  });
});

sc.dynamicallyToggleEmotionInputField = function() {
  return $(".emotion-name-group.form-group select").on("change", function(event) {
    var $target;
    $target = $(event.currentTarget);
    if ($target.find("option:selected").val() === "") {
      return $target.closest(".new_emotional_rating").find(".written-option").show();
    } else {
      var writtenOption;
      $writtenOption = $target.closest(".new_emotional_rating").find(".written-option");
      $writtenOption.hide();
      return $writtenOption.find("input").val("");
    }
  });
};

sc.rateEmotions = function(formContainers, path, partial) {
  sc.dynamicallyToggleEmotionInputField();
  $("#add-forms").on("click", function() {
    var count;
    count = $(formContainers).length;
    $("#forms-container").append("<div id='subcontainer-" + count + "'>" + partial + "</div>");
    sc.dynamicallyToggleEmotionInputField();
    return false;
  });
  $("#submit-forms").on("click", function(event) {
    event.preventDefault();
    _.each($(formContainers), function(form, index, list) {
      var $form;
      $form = $(form);
      return $.ajax({
        async: false,
        data: $form.serialize(),
        dataType: "script",
        type: "POST",
        url: $form.attr("action"),
        success: function() {
          if ((index + 1) === list.length) {
            window.location.href = path;
          }
        }
      });
    });
    return false;
  });
};
