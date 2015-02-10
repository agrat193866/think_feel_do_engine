# Represents a single Participant authentication event.
class ParticipantLoginEvent < ActiveRecord::Base
  belongs_to :participant

  validates :participant, presence: true
end
