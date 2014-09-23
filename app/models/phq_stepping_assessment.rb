# PHQ-9 Stepping Assessment in a well-formatted testable object
class PhqSteppingAssessment
  attr_accessor :date, :score, :week_of_assessment,
                :missing_but_copied, :missing_with_no_fallback,
                :missing_answers_count

  def initialize(*args)
    # [0]date, [1]score, [2]week_in_study, [3]week_of_assessment
    # (when copying), [4]missing-no fallback boolean,
    # [5]the entire assessment object (first call from table)
    @date = args[0]
    @score = args[1]
    if args[3].nil?
      @week_of_assessment = find_week_of_assessment(args[2])
    else
      @week_of_assessment = args[3]
    end
    @missing_but_copied = (!args[3].nil?) ? args[4].nil? : false
    @missing_with_no_fallback = (!args[4].nil?) ? args[4] : false
    missing_answers_count = false
    unless args[5].nil?
      missing_answers_count = fill_in_unanswered_questions(args[5])
    end
    @missing_answers_count = (!args[5].nil?) ? missing_answers_count : 0
  end

  def self.convert_from_score(hash, week_in_study)
    converted_array = []
    hash.each do |date, score|
      converted_array.push(PhqSteppingAssessment.new(
                            date,
                            score,
                            week_in_study
                            )
                          )
    end
    converted_array
  end

  def self.convert_from_assessment_objects(hash, week_in_study)
    converted_array = []
    hash.each do |date, assessment|
      converted_array.push(PhqSteppingAssessment.new(
                            date,
                            assessment.score,
                            week_in_study,
                            nil,
                            false,
                            assessment
                            )
                          )
    end
    converted_array
  end

  def self.convert_from_hash(hash, week_in_study)
    assessment_array = []
    if hash.first[1].is_a? Fixnum
      # Insert an assessment without being concerned about missing
      # values. Helpful for testing and for inserting copied
      # assessment data.
      assessment_array = convert_from_score(hash, week_in_study)
    else
      assessment_array = convert_from_assessment_objects(hash, week_in_study)
    end
    assessment_array
  end

  private

  def fill_in_missing_value(question)
    (question.nil?) ? 1.5 : question
  end

  def fill_in_unanswered_questions(assessment)
    missing_count = 9 - assessment.number_answered
    return 0 if missing_count == 0
    score =  fill_in_missing_value(assessment.q1)
    score += fill_in_missing_value(assessment.q2)
    score += fill_in_missing_value(assessment.q3)
    score += fill_in_missing_value(assessment.q4)
    score += fill_in_missing_value(assessment.q5)
    score += fill_in_missing_value(assessment.q6)
    score += fill_in_missing_value(assessment.q7)
    score += fill_in_missing_value(assessment.q8)
    score += fill_in_missing_value(assessment.q9)
    @score = score
    missing_count
  end

  def find_week_of_assessment(week_in_study)
    date_in_week_one = Date.today - (week_in_study - 1).weeks
    first_sunday = date_in_week_one - date_in_week_one.wday
    first_saturday = date_in_week_one.end_of_week(:sunday)
    return - 1 if @date < first_sunday

    last_saturday = @date.end_of_week(:sunday)

    # Week 1 would be (0/7) + 1 = 1, #Week 2 would be (7/7) + 1 = 2, etc
    (last_saturday - first_saturday) / 7 + 1
  end
end