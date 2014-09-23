showWarningInfo = function(rows, span, flag){
  console.log(flag,rows.hasClass(flag));
  if(rows.hasClass(flag))
    span.addClass("show_suffix_info");
  else
    span.removeClass("show_suffix_info");
};
enablePHQExplanationTable = function(){
  $(".label-phq").off("click touchstart").on("click touchstart", function(){
      //Variables
      var studyID, patientID, conditionalRows;
      //Constants
      var PATIENT_ID, EXPLANATION_DIV, SEPARATORS;

      PATIENT_ID = $("#phq_patientID");
      EXPLANATION_DIV = $("div#phq_suggestion_explanation_div");
      SEPARATORS = $("#phq_suggestion_explanation_table, #sep_after_explanation_table");

      patientID = $(this).parents("tr").data("studyId");
      studyID = $(this).parents("tr").attr("id");

      if(PATIENT_ID.attr("data-last_opened") == studyID){
        EXPLANATION_DIV.removeClass("show_suggestion");
        PATIENT_ID.attr("data-last_opened", "PATIENT");
        return;
      }

      if($(this).text() == "No Completed Assessments"){
          EXPLANATION_DIV.removeClass("show_suggestion");
          return;
      }
      else
      {
        $("#phq_patientSuggestion").text($("#phq_summary_" + studyID).attr("data-detailed_suggestion"));
      }

      if($(this).text() == "No; Too Early") SEPARATORS.addClass("no-explanation");
      else SEPARATORS.removeClass("no-explanation");
     
      PATIENT_ID.text(patientID);
      PATIENT_ID.attr("data-last_opened", studyID);
      $("#phq_weekInStudy span").text($("#phq_summary_" + studyID).attr("data-week"));

      $("#phq_suggestion_explanation_table tbody").html($("#phq_summary_" + studyID).clone().find("tr"));
      $("#phq_suggestion_test_results tbody").html($("#test_summary_" + studyID).clone().find("tr"));
      
      conditionalRows = EXPLANATION_DIV.find("tr");

      showWarningInfo(conditionalRows,$("#phq_copy_notice"), "copied_row");
      showWarningInfo(conditionalRows,$("#phq_missing_notice"), "lost_row");
      showWarningInfo(conditionalRows,$("#phq_answers_missing_notice"), "missing_answers_row");
      showWarningInfo(conditionalRows,$("#phq_unreliable_notice"), "unreliable_row");

      EXPLANATION_DIV.addClass("show_suggestion");
    });

  $("#phq_suggestion_explanation_div").off("click touchstart").on("click touchstart", function(){
    $(this).removeClass("show_suggestion");
     $("#phq_patientID").attr("data-last_opened", "PATIENT");
  });

  $(document).off("patient:rendered", enablePHQExplanationTable).on("patient:rendered", enablePHQExplanationTable);

};
