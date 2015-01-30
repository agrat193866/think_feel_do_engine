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

    def phq_notice_copied(tested_weeks, notices)
      if tested_weeks.map(&:missing_but_copied).include?(true)
        notices << "#{fa_icon("copy")} \
        PHQ9 assessment missing this week \
        - values copied from previous assessment."
      end
    end

    def phq_notice_lost(tested_weeks, notices)
      if tested_weeks.map(&:missing_with_no_fallback).include?(true)
        notices << "#{fa_icon("ban")} \
        PHQ9 assessment missing this week \
        - no previous assessment data to copy from."
      end
    end

    def phq_notice_missing_some_answers(tested_weeks, notices)
      question_counts = tested_weeks.map(&:missing_answers_count)
      if question_counts.include?(1) ||
        question_counts.include?(2) ||
        question_counts.include?(3)
        notices << "#{fa_icon("question")} \
        PHQ9 assessment missing answers for up to 3 questions \
        - using 1.5 to fill them in."
      end
    end

    def phq_notice_unreliable(tested_weeks, notices)
      question_counts = tested_weeks.map(&:missing_answers_count)
      disqualify_array = Array(4..9)
      if !(question_counts & disqualify_array).empty?
        notices << "#{fa_icon("question-circle")} \
        PHQ9 assessment missing answers for \
        more than 3 questions - data unreliable."
      end
    end

    def phq_notices(assessments)
      notices = []
      phq_notice_copied(assessments, notices)
      phq_notice_lost(assessments, notices)
      phq_notice_missing_some_answers(assessments, notices)
      phq_notice_unreliable(assessments, notices)
      notices.uniq
    end
  end
end
