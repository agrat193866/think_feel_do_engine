# A thought recorded by a Participant.
class Thought < ActiveRecord::Base
  EFFECTS = {
    helpful: "helpful",
    harmful: "harmful",
    neither: "neither"
  }
  IDENTIFIED = "identified"
  ASSIGNED_A_PATTERN = "Assigned a pattern to"
  RESHAPED = "Reshaped"

  belongs_to :participant
  belongs_to :pattern, class_name: "ThoughtPattern", foreign_key: :pattern_id

  before_validation :clean_attributes

  validates :participant, :content, :effect, presence: true
  validates :effect, inclusion: { in: EFFECTS.values }

  delegate :description,
           :recommendations,
           :title,
           to: :pattern,
           prefix: true,
           allow_nil: true

  scope :helpful, -> { where(effect: EFFECTS[:helpful]) }

  scope :harmful, -> { where(effect: EFFECTS[:harmful]) }

  scope :no_pattern, -> { where(pattern_id: nil) }

  scope :unreflected, lambda {
    where(effect: EFFECTS[:harmful])
      .where(arel_table[:challenging_thought].eq(nil)
        .or(arel_table[:challenging_thought].eq(""))
        .or(arel_table[:act_as_if].eq(nil))
        .or(arel_table[:act_as_if].eq("")))
  }

  scope :last_seven_days, lambda {
    where(
      arel_table[:created_at]
        .gteq(Time.current.advance(days: -7).beginning_of_day))
  }

  scope :for_day, lambda { |time|
    where(
      arel_table[:created_at]
        .gteq(time.beginning_of_day)
        .and(arel_table[:created_at].lteq(time.end_of_day))
    )
  }

  def status_label
    if !pattern_id && !challenging_thought
      IDENTIFIED
    elsif pattern_id && !challenging_thought
      ASSIGNED_A_PATTERN
    elsif challenging_thought
      RESHAPED
    end
  end

  def shared_description
    "Thought: #{ content }"
  end

  private

  def clean_attributes
    def clean_attribute(attr)
      if self[attr].respond_to?(:strip)
        cleaned = self[attr].strip
        send("#{ attr }=", cleaned == "" ? nil : cleaned)
      end
    end

    clean_attribute(:challenging_thought)
    clean_attribute(:act_as_if)
  end
end
