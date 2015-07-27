# Stepping suggestion based on Participant PHQ-9 results.
#
# An explanation of the algorithm:
#
# Weeks EARLIEST_ELIGIBLE_STEPPING_WEEK - 8
# If PHQ-9 >= 17 at two consecutive weeks, then "step" t-CBT
# If PHQ-9 < 17 at Week 5-8, then "stay" i-CBT
# If PHQ-9 < 5 at two consecutive weeks, schedule "post-engagement" coach call
# Week 9-13
# If PHQ-9 >= 13 at two consecutive weeks, then "step" t-CBT
# If PHQ-9 < 13 and >= 5 at Week 10-13, then "stay" i-CBT
# If PHQ-9 < 5 at two consecutive weeks, schedule "post-engagement" coach call
# Week 14-20
# If PHQ-9 >= 10 at two consecutive weeks, then "step" t-CBT
# If PHQ-9 < 10 and >= 5, then "stay" i-CBT
# If PHQ-9 < 5 at two consecutive weeks, schedule "post-engagement" coach call
class PhqStepping
  EARLIEST_ELIGIBLE_STEPPING_WEEK = 5

  attr_accessor :assessments, :week, :urgency, :suggestion,
                :detailed_suggestion, :step, :stay, :release, :range_start

  # assessments = [{date => score},{date => score}, ... ]
  def initialize(assessments, study_start_date)
    set_initial_values(assessments, study_start_date)
    return unless set_phq_score_ranges
    return unless prep_data_for_validation
    # Return if the data is unreliable, the coach needs to consult
    # and cannot use the automatic algorithm
    return unless validate_data_reliability
    # Most important test, the outcome determines whether to step
    # priority over other tests
    @step = consecutive_high_weeks?
    return if @step
    # At this point either way it has to be "No" (Don't step)
    @urgency = "success"
    # Least important test, if this returns true nothing is changed
    @stay = mid_range_scores?
    # Adds to test_range; if this returns true we suggest the coach look at
    # post engagement options.
    @release = consecutive_low_weeks?
  end

  def results
    { step?: @step, stay?: @stay, release?: @release, upper_limit: @upper_limit,
      lower_limit: @lower_limit, current_week: @week, range_start: @range_start
    }
  end

  def set_initial_values(assessments, study_start_date)
    @weeks_range = []
    @skip_flag = [false]
    @assessments = assessments
    @study_start_date = study_start_date
    @week = ((Date.current + 1 - study_start_date).days / 1.week).ceil
    @upper_limit = 17
    @upper_prev_limit = 17
    @lower_limit = 0
    @range_start = (@week < 9) ? EARLIEST_ELIGIBLE_STEPPING_WEEK : 9
    @range_start = 14 if (@week >= 14)
    @edge_week = (@week == @range_start)
    @urgency = "danger"
    @suggestion = "YES*"
    @detailed_suggestion = "No assessments passed to the algorithm. "\
                       "An error may have occurred"
  end

  def validate_data_reliability
    if @assessments.any? do |assessment|
      assessment.missing_answers_count > 3
    end
      @urgency = "warning"
      @suggestion = "Consult - Missing Data"
      @detailed_suggestion = "One or more assessments are missing more"\
                        " than than three answers. Stepping should be"\
                        " determined via consultation instead."
      false
    else
      true
    end
  end

  def set_phq_score_ranges
    if @week < EARLIEST_ELIGIBLE_STEPPING_WEEK
      @urgency = "warning"
      @suggestion = "No; Too Early"
      @detailed_suggestion = "Stay on i-CBT; Too early to determine stepping."
      return false
    elsif @week >= 9 && @week <= 13
      @upper_limit = 13
      @lower_limit = 5
    elsif (@week >= 14)
      @upper_limit = 10
      @upper_prev_limit = 13
      @lower_limit = 5
    end
    true
  end

  def assessments_exist?
    if @assessments.nil? || @assessments.count == 0
      @urgency = "danger"
      @suggestion = "YES*"
      @detailed_suggestion = "No assessments passed to the algorithm. "\
                             "An error may have occurred"
      return false
    end
    true
  end

  def copy_previous_assessment(to_copy, target_week)
    date_offset = (target_week - to_copy.week_of_assessment).weeks
    copy = PhqSteppingAssessment.new(
      to_copy.date + date_offset,
      to_copy.score,
      @study_start_date,
      target_week
    )
    copy.missing_answers_count = to_copy.missing_answers_count
    @assessments.push(copy)
  end

  def sort_assessments
    @assessments.sort! do |a, b|
      a.week_of_assessment.to_i <=> b.week_of_assessment.to_i
    end
  end

  def filter_assessments(start)
    if start == @week
      start -= 1
    end
    @assessments.select! do |assessment|
      assessment.week_of_assessment.to_i >= start &&
        assessment.week_of_assessment.to_i <= @week
    end
  end

  def get_assessment_by_week(week)
    found = @assessments.select do |assessment|
      assessment.week_of_assessment.to_i == week
    end
    found ? found[0] : false
  end

  def assessment_on_week_exists?(week)
    !get_assessment_by_week(week).nil?
  end

  def prep_data_for_validation
    # Convert the hash of date => score into an easily queried array of objects
    return false unless assessments_exist?
    @assessments = PhqSteppingAssessment
                   .convert_from_hash(@assessments, @study_start_date)
    # Handle filling in missing phq assessment data
    unless build_complete_record
      @urgency = "danger"
      @suggestion = "YES*"
      @detailed_suggestion = "Patient has no completed assessments until "\
                             "after week 3. Stepping algorithm not run; "\
                             "please use discretion."
      sort_assessments
      return false
    end
    true
  end

  def fill_in_missing_assessments
    i = @range_start
    while i <= @week
      unless assessment_on_week_exists?(i)
        copy_previous_assessment(get_assessment_by_week(i - 1), i)
      end
      i += 1
    end
    sort_assessments
  end

  def fill_in_missing_unknown_assessments
    first_assessment = @assessments.first
    while first_assessment.week_of_assessment.to_i >= 3
      first_assessment = PhqSteppingAssessment.new(
        first_assessment.date - 1.week,
        "Unknown",
        @study_start_date,
        (first_assessment.week_of_assessment.to_i - 1),
        true
      )
      @assessments.push(first_assessment)
    end
  end

  def fill_in_initial_week
    previous_assessments = @assessments.select do |assessment|
      assessment.week_of_assessment.to_i < @range_start
    end
    copy_score_from = previous_assessments.max_by(&:week_of_assessment)
    unless assessment_on_week_exists?(@range_start)
      copy_previous_assessment(copy_score_from, @range_start)
    end
    if @edge_week
      range_for_this_period = @range_start
      @range_start = copy_score_from.week_of_assessment
      fill_in_missing_assessments
      @range_start = range_for_this_period
    end
  end

  def previous_data_to_infer_from?
    unless @assessments.any? do |assessment|
             assessment
             .week_of_assessment
             .to_i < EARLIEST_ELIGIBLE_STEPPING_WEEK
           end
      sort_assessments
      fill_in_missing_unknown_assessments
      fallback_range = @range_start
      @range_start = 3
      fill_in_missing_assessments
      @range_start = fallback_range
      filter_assessments(@range_start)
      return false
    end
    true
  end

  def build_complete_record
    return false unless previous_data_to_infer_from?
    # Prep this period (week EARLIEST_ELIGIBLE_STEPPING_WEEK - 8, 9-13, 14+)
    # by making sure at least the start date has an associated assessment
    fill_in_initial_week
    filter_assessments(@range_start)
    sort_assessments
    fill_in_missing_assessments
    true
  end

  def consecutive_high_weeks?
    prev_score = @assessments.first.score
    @assessments.drop(1).each do |assessment|
      if assessment.score >= @upper_limit &&
         prev_score >= (@edge_week ? @upper_prev_limit : @upper_limit)
        @urgency = "danger"
        @suggestion = "YES"
        @detailed_suggestion = "Step to t-CBT"
        @step = true
        return @step
      end
      prev_score = assessment.score
    end

    @step = false
  end

  def set_up_mid_range
    if @edge_week && @week < 14
      @suggestion = "No*"
      @detailed_suggestion = "Stay on i-CBT; "\
                             "Using data from last period as well"
      return false
    end
    subset_from = (@week < 9) ? 5 : 10
    subset_from = 14 if @week >= 14
    @assessments_subset = @assessments.select do |assessment|
      assessment.week_of_assessment.to_i >= subset_from
    end
    true
  end

  def mid_range_scores?
    return nil unless set_up_mid_range
    if @assessments_subset.any? do |assessment|
         assessment.score >= @lower_limit &&
         assessment.score < @upper_limit
       end
      @suggestion = "No"
      @detailed_suggestion = "Stay on i-CBT"
      return true
    end
    if @edge_week && @week == 14
      @suggestion = "No*"
      @detailed_suggestion = "Stay on i-CBT; "\
                             "Using data from last period as well"
    end
    false
  end

  def consecutive_low_weeks?
    prev_score = @assessments.first.score
    @assessments.drop(1).each do |assessment|
      if assessment.score < 5 && prev_score < 5
        @suggestion = "No - Low Scores"
        @detailed_suggestion = "Stay on i-CBT or schedule post engagement call"
        return true
      end
      prev_score = assessment.score
    end
    false
  end
end
