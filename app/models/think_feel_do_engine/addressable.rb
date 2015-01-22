module ThinkFeelDoEngine
  # Labels the sender and recipient of a message.
  module Addressable
    def from(user = nil)
      if sender.id == user.try(:id)
        "You"
      elsif sender.try(:study_id)
        sender.study_id
      elsif CoachAssignment.exists?(participant_id: recipient_id,
                                    coach_id: sender.id)
        "Coach"
      else
        "Moderator"
      end
    end

    def to(user = nil)
      if recipient_id == user.try(:id)
        "You"
      elsif recipient.try(:study_id)
        recipient.study_id
      elsif CoachAssignment.exists?(participant_id: sender.id,
                                    coach_id: recipient_id)
        "Coach"
      else
        "Moderator"
      end
    end
  end
end
