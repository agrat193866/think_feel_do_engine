# A period of time during which a Participant was awake and may have
# participated in Activities.
class AwakePeriod < ActiveRecord::Base
  belongs_to :participant

  validates :participant, :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :awake_periods_cannot_overlap

  scope :periods_for, lambda { |start_time, end_time|
    where(
      arel_table[:start_time]
      .lteq(end_time)
      .and(
        arel_table[:end_time]
        .gteq(start_time)
      )
    )
  }

  private

  def awake_periods_cannot_overlap
    overlapping_period_exists =
      participant
      .awake_periods
      .periods_for(start_time, end_time)
      .limit(1)
      .count == 1
    if overlapping_period_exists
      errors.add(:base, "This awake period already exists")
    end
  end

  def end_time_after_start_time
    if start_time && end_time && end_time <= start_time
      errors.add :end_time, "Must be after the start time"
    end
  end
end
