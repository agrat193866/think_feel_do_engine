module ThinkFeelDoEngine
  # Used to display a warning message to clinicians if
  # a user scores a 3 on a the PHQ-9
  module PhqAssessmentHelper
    def phq_warning(score)
      if score == 3
        "<div class='label label-danger'>PHQ-9 WARNING: #{ score }</div>"
          .html_safe
      else
        score
      end
    end
  end
end
