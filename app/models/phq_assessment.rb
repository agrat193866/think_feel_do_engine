# Collected responses from one Participant PHQ-9 assessment session.
class PhqAssessment < ActiveRecord::Base
  MIN_QUESTION_SCORE = 0
  MAX_QUESTION_SCORE = 3
  QUESTION_ATTRIBUTES = :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9
  SUICIDAL_SCORE = 3

  belongs_to :participant

  validates :participant, :release_date, presence: true
  validates :release_date, uniqueness: { scope: :participant_id }
  validate :scores_valid

  scope :latest_updated, -> { order(updated_at: :desc) }

  def self.most_recent
    latest_updated.first
  end

  def answered_questions
    @answered_questions ||= remove_nils
  end

  def completed?
    number_answered == QUESTION_ATTRIBUTES.count
  end

  def number_answered
    answered_questions.count
  end

  def score
    answered_questions.inject(:+)
  end

  def suicidal?
    q9 == SUICIDAL_SCORE
  end

  private

  def remove_nils
    QUESTION_ATTRIBUTES.map { |answer| self[answer] }.compact
  end

  def scores_valid
    return unless number_answered > 0

    if answered_questions.min < MIN_QUESTION_SCORE ||
       answered_questions.max > MAX_QUESTION_SCORE
      errors.add(:base, "scores must be between #{ MIN_QUESTION_SCORE } " \
                        "and #{ MAX_QUESTION_SCORE } inclusive")
    end
  end
end
