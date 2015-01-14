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
end
