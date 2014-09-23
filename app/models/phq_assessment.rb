# Collected responses from one Participant PHQ-9 assessment session.
class PhqAssessment < ActiveRecord::Base
  belongs_to :participant

  validates :participant, :release_date, presence: true
  validates :release_date, uniqueness: { scope: :participant_id }
  validate :scores_valid

  def remove_nils
    [q1, q2, q3, q4, q5, q6, q7, q8, q9].compact
  end

  def number_answered
    remove_nils.count
  end

  def completed?
    number_answered == 9
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

    if remove_nils.min < 0 || remove_nils.max > 3
      errors.add(:base, "scores must be between 0 and 3 inclusive")
    end
  end
end
