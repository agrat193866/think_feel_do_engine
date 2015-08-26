(function() {
  sc.activityTrackerEventHandlers = function(activityTracker) {
    $("#submit_activities").on("click", activityTracker.handleSubmitClick);

    $(".intensity_btn").on("click", activityTracker.handleIntensityClick);

    $(".btn-date_picker").on("click", function(){
      $(this).parents("div.input-group").children("input").datepicker("show");
    });

    $(".btn-time_picker").on("click", function(){
      $(this).parents("div.input-group").children("input").timepicker("showWidget");
        activityTracker.showRater(activityTracker.getFormID($(this).attr("id")));
    });

    $("button.copy_btn").on("click", activityTracker.handleCopyClick);

    $("input.form-control").on("click", function(){
      activityTracker.showRater(activityTracker.getFormID($(this).attr("id")));
    });

    // Focus
    $(".date_picker, .time_picker").on("focus", function() {
      activityTracker.showRater(activityTracker.getFormID($(this).attr("id")));
    });

    // Keys
    $("input.form-control").on("keypress", activityTracker.handleEnterKey);

    // Change
    $(".date_picker, .time_picker").on("change", function(){
      // prevent times in the past
      var date = sc.datejs($(".date_picker").datepicker("getDate"));
      var time = $(".time_picker").data("timepicker").getTime();
      var datetime = sc.datejs(date.format("YYYY-MM-DD ") + time, "YYYY-MM-DD hh:mm A");
      var futureTime = sc.datejs().add(60, "minutes");
      if (datetime.isBefore(futureTime, "minute")) {
        $(".time_picker").timepicker("setTime", futureTime.format("hh:mm A"));
      }

      activityTracker.orderSummaryTable(false, activityTracker.getFormID($(this).attr("id")));
    });
  };

  sc.activityTracker = function(path){
    var self = this;

    this.path = path;
    this.waitForTable = true;
    this.warningSpan = document.createElement("span");
    $(this.warningSpan).attr("class", "label label-warning").text("Not Rated");

    var today = new Date();

    $(".date_picker").datepicker({
      changeMonth: true,
      changeYear: true,
      dateFormat: dateFormat(),
      minDate: today,
      yearRange: today.getFullYear() + ":" + (today.getFullYear()+1)
    });

    $(".date_picker").datepicker('setDate', today);

    $(".time_picker").timepicker({disableFocus:true});

    $('.date_picker').on('focus', function(){
       $(".btn-date_picker").parents("div.input-group").children("input").blur();
    });


    this.handleEnterKey = function(e) {
      if(e.keyCode == 13) {
        self.handleSubmitClick();
        e.preventDefault();
        return false;
      }
    };

    this.handleCopyClick = function(e) {
      var copyToId, copyFromId, aName, pIntensity, aIntensity,
      newPleasureSelection, newAccomplishmentSelection;

      copyToId = self.getFormID($(this).attr("id"));
      copyFromId = copyToId - 1;

      if(copyToId < 0) return false;

      //Grab the values from the previous entry
      aName = $("#activity_type_"+ copyFromId).val();
      pIntensity = $("#pleasure_"+ copyFromId + " select")[0].options[$("#pleasure_"+ copyFromId + " select")[0].selectedIndex].value;
      aIntensity = $("#accomplishment_"+ copyFromId + " select")[0].options[$("#accomplishment_"+ copyFromId + " select")[0].selectedIndex].value;

      //Paste the activity title
      $("#activity_type_"+copyToId).val(aName);

      //Copy the pleasure rating
      self.copyIntensity(copyToId, "pleasure", pIntensity);

      //Copy the accomplishment rating
      self.copyIntensity(copyToId, "accomplishment",aIntensity);

      return false;
    };

    this.handleIntensityClick = function(e) {
      var intensity, possibleParents, wholeNumId;

      intensity = $(this).attr("data-intensity");
      possibleParents = $(this).parents(".rateIntensity");
      wholeNumId = self.getFormID($(possibleParents[0]).attr("id"));

      if(possibleParents == null || possibleParents == undefined) return;

      //Check if both pleasure and accomplishment have been rated
      $(possibleParents[0]).removeClass("rateIntensity");

      //Re-order the table if on the appropriate page
      if ($(".start_time_"+wholeNumId).length > 0) {
        self.orderSummaryTable(false, wholeNumId);
      }
    };

    this.handleSubmitClick = function(e) {
      var shared_item_name;

      if($(".activity_shared_item_true")[0]) {
        shared_item_name = "activity_shared_item_true";
      } else {
        shared_item_name = "planned_activity_shared_item_true";
      }
      if(validatePublicNoEvent(e, shared_item_name)) {
          var $forms = $("form.activity_form");

          sc.displayErrors();

          if ($forms.length === 1) {
              $(".start_time_0").val(self.concatStringFromPickers(0));
              if ($('.has-error').length === 0) {
                $forms.submit();
              }

              return false;
          } else {
              return _.each($forms, function (form, index, list) {
                  var $form = $(form);

                  if ($(".form-group.has-error").length === 0) {
                      $(".start_time_" + index).val(self.concatStringFromPickers(index));

                      $.ajax({
                          async: false,
                          timeout: 600,
                          type: "POST",
                          url: $form.attr("action"),
                          data: $form.serialize(),
                          success: function () {
                              if (index === list.length - 1) {
                                  return window.location = self.path;
                              }
                          },
                          dataType: "script"
                      });
                  }

                  return false;
              });
          }
      }
    };

    this.showRater = function(numId) {
      $("div.form-group").removeClass("rateIntensity");
      $("#pleasure_"+numId).addClass("rateIntensity");
      $("#accomplishment_"+numId).addClass("rateIntensity");
    };

    this.orderSummaryTable = function(insert, updateId) {
      var already, soon, row, niceTime, niceDate, tempCells,warningSpan;
      if(insert && this.waitForTable) {

        //Grab dates already in table
        already = self.grabCurrentActivityDates();

        //Grab dates not in table
        soon = self.grabPendingActivityDates();

        //Now insert that data into the table


        _.each(soon,function(sval, i){
          if(already.length > 0){
            _.every(already, function(aval, j){
              if(aval.date > sval.date)
              {
                self.insertRow(sval, i, j);
                return false;
              }
              else if(j == already.length - 1)
              {
                self.insertRow(sval, i, j);
              }
              return true;
            });
          }
          else{
            self.insertRow(sval, i, 0);
          }
        });
        self.waitForTable = false;
        return;
      }
      row = $("#future_row_"+updateId)[0];

      niceDate = self.concatDateFromPickers(updateId);
      niceTime = niceDate.getTime();

      tempCells = [];

      //keep name constant
      tempCells.push(
        $($(row).children()[0]).text()
      );

      //update date
      tempCells.push(self.concatStringFromPickers(updateId));

      //update pleasure
      tempCells.push(
        $("#p_indicator_" + updateId).text() == "Not Rated" ?
        $(self.warningSpan).clone() :
         $("#p_indicator_"+ updateId).text()
      );

      //update accomplishment
      tempCells.push(
        $("#a_indicator_" + updateId).text() == "Not Rated" ?
        $(self.warningSpan).clone() :
        $("#a_indicator_"+ updateId).text()
      );

      //compare and reorder the updated row in the table
      already = self.grabCurrentActivityDates(updateId);

      row = self.makeRow(row, tempCells);
      _.every(already,function(aval,j){
          if(aval.date > niceTime)
          {
            $('table#previous_activities tr:eq('+(j+1)+')').before(row);
            return false;
          }
          else if(j == already.length - 1)
          {
            $('table#previous_activities tr:eq('+(j+1)+')').after(row);
          }
          return true;
        });
    };

    /* Utility - [Shared/General] */
    this.getFormID = function(str) {
      if(typeof str === "undefined" || str === null || str.length === 0) return -1;
      var matches = str.match(/\d+$/);
      if (matches) return matches[0];
      return -1;
    };

    /* Utility - [DO#1 Awareness - Data Preparation] */
    this.copyIntensity = function(toId, typeString, newIntensity) {
      newSelection = $("#"+typeString+"_"+ toId + " select")[0];
      newSelection.selectedIndex = newIntensity;
    };

    /* Utility - [DO#2 Planning - Data Preparation] */

    this.concatDateFromPickers = function (id) {
      var datestring;

      //Much more clear compared to before
      datestring = $("#future_date_picker_"+id).val();
      datestring += " ";
      datestring += $("#future_time_picker_"+id).val();
      return new Date(datestring);
    };

    this.concatStringFromPickers = function (id) {
      var date = self.concatDateFromPickers(id);
      return $.datepicker.formatDate(dateFormat(), date) +
              " " +
              self.formatAMPM(date);
    };

    this.formatAMPM = function(date) {
      var hours, minutes, ampm;

      hours = date.getHours();
      minutes = date.getMinutes();
      ampm = hours >= 12 ? 'PM' : 'AM';

      hours = hours % 12;
      hours = hours ? hours : 12; // the hour '0' should be '12'
      minutes = minutes < 10 ? '0'+minutes : minutes;

      return hours + ':' + minutes + ' ' + ampm;
    };

    /* Utility - [DO#2 Planning - Summary Table] */

    this.insertRow = function(sval, sourceIndex, destIndex) {
      var row, niceDate, cells;

      //Make a new row to mess with
      row = document.createElement("tr");
      $(row).attr("id", "future_row_"+sourceIndex).attr("class","success");

      //Set up the parameters for this row
      cells = [];
      nicedate = new Date(sval.date);

      cells.push($("#future_activity_title_" + sourceIndex).text());
      cells.push($.datepicker.formatDate(dateFormat(), nicedate) + " " + self.formatAMPM(nicedate));
      cells.push($(self.warningSpan).clone());
      cells.push($(self.warningSpan).clone());

      row = self.makeRow(row,cells);
      if($('table#previous_activities tr').length > 1)
      $('table#previous_activities tr:eq('+ (destIndex+1) +')').after(row);
      else
      $('table#previous_activities tbody').append(row);
    };

    this.makeRow = function(row, args) {
      var newRow, newTag;
      newRow = $.map(args, function(val, i){
        newTag = document.createElement("td");
        if(val.length == 1 && val[0].nodeType == 1) return $(newTag).append(val[0]);
        return $(newTag).text(val);
      });
      $(row).empty();
      return $(row).append(newRow);
    };

    this.grabCurrentActivityDates = function(ignoreId) {
      var already, id, d, oldActivity;


        already = $.map($('table#previous_activities tbody tr td:nth-child(2)'),
        function(val, i){
          id = self.getFormID($(val).parent().attr("id"));
            d = new Date($(val).text());
            oldActivity = {date:d.getTime(), index: i};
            return oldActivity;

        });
        return already;
    };

    this.grabPendingActivityDates = function() {
      var soon, d, newActivity;
      soon = $.map($(".date_picker"), function(val, i)
          {
            d = self.concatDateFromPickers(i);
            newActivity = {date:d.getTime(), index: i};
            return newActivity;
          });
      //Just like in classic sorting methods, first we sort the data we're adding.
      return soon.sort(function(a, b){
          return a.date - b.date;
      });
    };


    $(".time_picker").timepicker("setTime", sc.datejs().add(60, "minutes").format("hh:mm A"));

    if ($(".start_time_0").length > 0) {
      self.orderSummaryTable(true);
    }

    sc.activityTrackerEventHandlers(this);
  };

  function dateFormat() {
    return 'M dd yy';
  };
})();

