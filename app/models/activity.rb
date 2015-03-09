# Represents a real-world activity of a participant.
class Activity < ActiveRecord::Base
  attr_accessor :activity_type_title,
                :activity_type_new_title,
                :in_review

  PLEASURABLE_CUTOFF = 6
  ACCOMPLISHED_CUTOFF = 6

  belongs_to :activity_type
  belongs_to :participant

  validates :activity_type, :participant, presence: true

  validate :actual_ratings!, on: :update, if: proc { |f| f.in_review }

  delegate :title, to: :activity_type, prefix: false, allow_nil: true

  before_validation :create_activity_type, :set_end_time
  validate :actual_accomplishable_updates, on: :update
  validate :predicted_intensities, :actual_intensities

  scope :for_day, lambda { |time|
    where(
      arel_table[:start_time]
      .gteq(time.beginning_of_day)
      .and(arel_table[:start_time].lteq(time.end_of_day))
    )
  }

  scope :accomplished, lambda {
    where(
      arel_table[:actual_accomplishment_intensity]
      .gteq(ACCOMPLISHED_CUTOFF)
    )
  }

  scope :pleasurable, lambda {
    where(
      arel_table[:actual_pleasure_intensity]
      .gteq(PLEASURABLE_CUTOFF)
    )
  }

  scope :in_the_past, lambda {
    where(
      arel_table[:end_time]
      .lt(Time.current)
    )
  }

  scope :last_seven_days, lambda {
    where(
      arel_table[:start_time]
      .gteq(Time.current.advance(days: -7).beginning_of_day)
    )
  }

  # To Do: fix naming and/or what is going on here
  # change to start_time and is_scheduled
  # and updated tests
  scope :unscheduled_or_in_the_future, lambda {
    where(
      arel_table[:start_time].eq(nil)
      .or(arel_table[:end_time].gt(Time.current))
    )
  }

  scope :reviewed_and_complete, lambda {
    where(is_reviewed: true)
      .where
      .not(
        predicted_accomplishment_intensity: nil,
        predicted_pleasure_intensity: nil,
        actual_accomplishment_intensity: nil,
        actual_pleasure_intensity: nil)
  }

  scope :reviewed_and_incomplete, lambda {
    where(is_reviewed: true)
      .where(
        actual_accomplishment_intensity: nil,
        actual_pleasure_intensity: nil)
      .where
      .not(
        predicted_accomplishment_intensity: nil,
        predicted_pleasure_intensity: nil)
  }

  scope :monitored, lambda {
    where(is_reviewed: false)
      .where(
        actual_accomplishment_intensity: nil,
        actual_pleasure_intensity: nil)
      .where
      .not(
        predicted_accomplishment_intensity: nil,
        predicted_pleasure_intensity: nil)
  }

  # To Do: fix naming and/or what is going on here
  # change to start_time
  # and updated tests
  scope :in_the_future, lambda {
    where(
      arel_table[:end_time].gt(Time.current)
    )
  }

  scope :planned, lambda {
    where(
      is_reviewed: false,
      actual_accomplishment_intensity: nil,
      actual_pleasure_intensity: nil)
      .where
      .not(
        predicted_accomplishment_intensity: nil,
        predicted_pleasure_intensity: nil)
  }

  scope :random, lambda {
    order("RANDOM()")
  }

  scope :were_planned, lambda {
    where
      .not(
        predicted_accomplishment_intensity: nil,
        predicted_pleasure_intensity: nil)
  }

  scope :with_actual_ratings, lambda {
    where
      .not(
        actual_accomplishment_intensity: nil,
        actual_pleasure_intensity: nil)
  }

  scope :unplanned, lambda {
    where(start_time: nil, end_time: nil)
  }

  scope :during, lambda { |start_time, end_time|
    where(
      arel_table[:start_time].gteq(start_time)
      .and(arel_table[:end_time].lteq(end_time))
    )
  }

  # Extend with virtual attributes.
  def self.attribute_names
    super + %w(activity_type_title activity_type_new_title)
  end

  def update_as_reviewed(params = {})
    update(
      params
      .merge(in_review: true, is_reviewed: true))
  end

  def actual_ratings!
    validate_actual_intensities!("accomplishment")
    validate_actual_intensities!("pleasure")
  end

  def actual_editable?
    if end_time && !reviewed_and_incomplete?
      end_time < Time.zone.now
    else
      false
    end
  end

  def status_label
    if monitored?
      "Monitored"
    elsif planned?
      "Planned"
    elsif reviewed_and_complete?
      "Reviewed & Completed"
    elsif reviewed_and_incomplete?
      "Reviewed & Incompleted"
    else
      "N/A"
    end
  end

  def monitored?
    not_reviewed? &&
      neither_intensity_is_rated?(:predicted) &&
      both_intensities_rated?(:actual)
  end

  def planned?
    not_reviewed? &&
      neither_intensity_is_rated?(:actual) &&
      both_intensities_rated?(:predicted)
  end

  def reviewed_and_complete?
    reviewed? &&
      both_intensities_rated?(:predicted) &&
      both_intensities_rated?(:actual)
  end

  def reviewed_and_incomplete?
    reviewed? &&
      neither_intensity_is_rated?(:actual) &&
      both_intensities_rated?(:predicted)
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

  def self.completion_score
    if reviewed_and_complete.count > 0
      (reviewed_and_complete.count * 100 / count).round
    else
      0
    end
  end

  private

  def both_intensities_rated?(type)
    accomplishment = send("#{type}_accomplishment_intensity")
    pleasure = send("#{type}_pleasure_intensity")
    !accomplishment.nil? && !pleasure.nil?
  end

  def either_intensity_is_rated?(type)
    accomplishment = send("#{type}_accomplishment_intensity")
    pleasure = send("#{type}_pleasure_intensity")
    !accomplishment.nil? || !pleasure.nil?
  end

  def neither_intensity_is_rated?(type)
    !either_intensity_is_rated?(type)
  end

  def reviewed?
    is_reviewed?
  end

  def not_reviewed?
    !reviewed?
  end

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

  def actual_intensities
    if (actual_accomplishment_intensity &&
        actual_pleasure_intensity.nil?) ||
       (actual_pleasure_intensity &&
        actual_accomplishment_intensity.nil?)
      errors.add :base, "When rating actual intensities, you must "\
                        "rate both pleasure and accomplishment."
    end
  end

  def predicted_intensities
    if (predicted_accomplishment_intensity &&
        predicted_pleasure_intensity.nil?) ||
       (predicted_pleasure_intensity &&
        predicted_accomplishment_intensity.nil?)
      errors.add :base, "When predicting, you must predict "\
                        "both pleasure and accomplishment."
    end
  end

  def validate_actual_intensities!(attribute)
    attribute_sym = "actual_#{attribute}_intensity".to_sym
    errors.add attribute_sym, "can't be blank." if send(attribute_sym).nil?
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