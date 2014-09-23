# The assignment of a Coach (User) to a Participant.
class CoachAssignment < ActiveRecord::Base
  belongs_to :participant
  belongs_to :coach, class_name: "User"

  validates :coach, :participant, presence: true

  delegate :email, to: :coach, prefix: false
end
