# PHQ-9 Stepping Assessment in a well-formatted testable object
class PhqSteppingAssessment
  attr_accessor :date, :score, :week_of_assessment,
                :missing_but_copied, :missing_with_no_fallback,
                :missing_answers_count

  def initialize(*args)
    # [0]date, [1]score, [2]study_start_date, [3]week_of_assessment
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

  def self.convert_from_score(hash, study_start_date)
    converted_array = []
    hash.each do |date, score|
      converted_array.push(PhqSteppingAssessment.new(
                             date,
                             score,
                             study_start_date
                           )
                          )
    end
    converted_array
  end

  def self.convert_from_assessment_objects(hash, study_start_date)
    converted_array = []
    hash.each do |date, assessment|
      converted_array.push(PhqSteppingAssessment.new(
                             date,
                             assessment.score,
                             study_start_date,
                             nil,
                             false,
                             assessment
                           )
                          )
    end
    converted_array
  end

  def self.convert_from_hash(hash, study_start_date)
    assessment_array = []
    if hash.first[1].is_a? Fixnum
      # Insert an assessment without being concerned about missing
      # values. Helpful for testing and for inserting copied
      # assessment data.
      assessment_array = convert_from_score(hash, study_start_date)
    else
      assessment_array = convert_from_assessment_objects(hash, study_start_date)
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

  # Assessments are always made available on the same day of the
  # week, starting on week 2 of study enrollment.
  def find_week_of_assessment(study_start_date)
    ((@date - study_start_date).days / 1.week).floor + 1
  end
end
