# Collected responses from one Participant PHQ-9 assessment session.
class PhqAssessment < ActiveRecord::Base
  MIN_QUESTION_SCORE = 0
  MAX_QUESTION_SCORE = 3
  QUESTION_COUNT = 9
  QUESTION_ATTRIBUTES = :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9

  belongs_to :participant

  validates :participant, :release_date, presence: true
  validates :release_date, uniqueness: { scope: :participant_id }
  validate :scores_valid

  def remove_nils
    QUESTION_ATTRIBUTES.map { |a| self[a] }.compact
  end

  def completed?
    number_answered == QUESTION_COUNT
  end

  def number_answered
    remove_nils.count
  end

  def score
    remove_nils.inject(:+)
  end

  def suicidal?
    q9 == 3
  end

  private

  def scores_valid
    return unless remove_nils.length > 0

    if remove_nils.min < MIN_QUESTION_SCORE ||
       remove_nils.max > MAX_QUESTION_SCORE
      errors.add(:base, "scores must be between #{ MIN_QUESTION_SCORE } " \
                        "and #{ MAX_QUESTION_SCORE } inclusive")
    end
  end
end
