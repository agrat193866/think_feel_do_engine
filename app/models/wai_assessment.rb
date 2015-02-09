# Collected responses from one Participant WAI assessment session.
class WaiAssessment < ActiveRecord::Base
  MIN_QUESTION_SCORE = 1
  MAX_QUESTION_SCORE = 5
  QUESTION_COUNT = 12
  QUESTION_ATTRIBUTES = :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9, :q10, :q11,
                        :q12

  belongs_to :participant

  validates :participant, :release_date, presence: true
  validates :release_date, uniqueness: { scope: :participant_id }
  validate :scores_valid

  private

  def scores_valid
    return unless remove_nils.length > 0

    if remove_nils.min < MIN_QUESTION_SCORE ||
       remove_nils.max > MAX_QUESTION_SCORE
      errors.add(:base, "scores must be between #{ MIN_QUESTION_SCORE } " \
                        "and #{ MAX_QUESTION_SCORE } inclusive")
    end
  end

  def remove_nils
    QUESTION_ATTRIBUTES.map { |a| self[a] }.compact
  end
end
