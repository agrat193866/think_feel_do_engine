# A thought recorded by a Participant.
class Thought < ActiveRecord::Base
  EFFECTS = ["helpful", "harmful", "neither"]

  belongs_to :participant
  belongs_to :pattern, class_name: "ThoughtPattern", foreign_key: :pattern_id

  validates :participant, :content, :effect, presence: true
  validates :effect, inclusion: { in: EFFECTS }

  delegate :description,
           :recommendations,
           :title,
           to: :pattern,
           prefix: true,
           allow_nil: true

  scope :helpful, -> { where(effect: "helpful") }

  scope :harmful, -> { where(effect: "harmful") }

  scope :no_pattern, -> { where(pattern_id: nil) }

  scope :unreflected, lambda {
    where(effect: "harmful")
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
      "Identified"
    elsif pattern_id && !challenging_thought
      "Assigned a pattern to"
    elsif challenging_thought
      "Reshaped"
    else
      "Shared"
    end
  end

  def shared_description
    "Thought: #{ content }"
  end
end
