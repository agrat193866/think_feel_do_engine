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
  validate :actual_accomplishable_updates, on: :update

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

  scope :last_seven_days, lambda {
    where(
      "activities.start_time >= ?",
      Time.current.advance(days: -7)
        .beginning_of_day
    ).in_the_past
  }

  scope :unscheduled_or_in_the_future, lambda {
    where(
      "activities.start_time IS NULL OR activities.end_time > ?",
      Time.current
    )
  }

  scope :completed, lambda {
    where(
      arel_table[:is_complete].eq(true)
      .or(
        arel_table[:noncompliance_reason].eq(true)
      )
    )
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

  def actual_editable?
    end_time < Time.zone.now if end_time
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

  def intensity_difference(attribute)
    actual_intensity = send("actual_#{attribute}_intensity")
    predicted_intensity = send("predicted_#{attribute}_intensity")
    if actual_intensity && predicted_intensity
      (actual_intensity - predicted_intensity).abs
    else
      "N/A"
    end
  end

  private

  def actual_accomplishable_updates
    actual_accomplishable_update("actual_accomplishment_intensity")
    actual_accomplishable_update("actual_pleasure_intensity")
  end

  def actual_accomplishable_update(accomplishable_attr)
    if end_time > Time.zone.now &&
       changed.include?(accomplishable_attr)
      errors.add accomplishable_attr.to_sym, "can't be updated "\
        "because activity is not in the past."
    end
  end

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
