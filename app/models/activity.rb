# Represents a real-world activity of a participant.
class Activity < ActiveRecord::Base
  attr_accessor :activity_type_title, :activity_type_new_title

  PLEASURABLE_CUTOFF = 6
  ACCOMPLISHED_CUTOFF = 6

  belongs_to :activity_type
  belongs_to :participant

  validates :activity_type, :participant, presence: true
  validates :is_complete, inclusion: { in: [true, false] }

  delegate :title, to: :activity_type, prefix: false, allow_nil: true

  before_validation :create_activity_type, :set_end_time

  scope :for_day, lambda { |datetime|
    where(
      "activities.start_time >= ? AND activities.start_time < ?",
      datetime.beginning_of_day, datetime.advance(days: 1).beginning_of_day)
  }

  scope :accomplished, lambda {
    where(
      "activities.actual_accomplishment_intensity >= ?",
      ACCOMPLISHED_CUTOFF
    )
  }

  scope :in_the_past, lambda {
    where("activities.end_time < ?", Time.current)
  }

  scope :unscheduled_or_in_the_future, lambda {
    where("activities.start_time IS NULL OR activities.end_time > ?",
          Time.current)
  }

  scope :in_the_future, lambda {
    where("activities.end_time > ?", Time.current)
  }

  scope :incomplete, lambda {
    where(is_complete: false)
      .where(noncompliance_reason: nil)
  }

  scope :pleasurable, lambda {
    where(
      "activities.actual_pleasure_intensity >= ?",
      PLEASURABLE_CUTOFF
    )
  }

  scope :random, lambda {
    order("RANDOM()")
  }

  scope :unplanned, lambda {
    where(start_time: nil, end_time: nil)
  }

  def self.during(start_time, end_time)
    where("start_time >= ? AND end_time <= ?", start_time, end_time)
  end

  # Extend with virtual attributes.
  def self.attribute_names
    super + %w(activity_type_title activity_type_new_title)
  end

  def completed?
    is_complete || noncompliance_reason
  end

  def was_recently_created?
    (Time.current - created_at) < 1.minute
  end

  def actual_pleasure_value
    Values::Pleasure.from_intensity(actual_pleasure_intensity)
  end

  def actual_accomplishment_value
    Values::Accomplishment.from_intensity(actual_accomplishment_intensity)
  end

  def predicted_accomplishment_value
    Values::Accomplishment.from_intensity(predicted_accomplishment_intensity)
  end

  def predicted_pleasure_value
    Values::Pleasure.from_intensity(predicted_pleasure_intensity)
  end

  def rated?
    actual_pleasure_intensity || actual_accomplishment_intensity
  end

  private

  def create_activity_type
    new_title = activity_type_new_title.present? ? activity_type_new_title :
      activity_type_title
    if new_title
      activity_types = participant.activity_types

      if activity_types.create(title: new_title)
        self.activity_type = activity_types.find_by_title(new_title)
      end
    end
  end

  def set_end_time
    unless start_time.nil?
      self.end_time = start_time + 1.hour
    end
  end
end
