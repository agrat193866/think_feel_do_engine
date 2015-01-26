module ThinkFeelDoEngine
  # Labels the sender and recipient of a message.
  module Addressable
    def from(user = nil)
      if sender.id == user.try(:id)
        "You"
      elsif sender.try(:study_id)
        sender.study_id
      elsif recipient.try(:active_group).try(:arm).try(:has_woz?)
        "Moderator"
      else
        "Coach"
      end
    end

    def to(user = nil)
      if recipient.id == user.try(:id)
        "You"
      elsif recipient.try(:study_id)
        recipient.study_id
      elsif sender.try(:active_group).try(:arm).try(:has_woz?)
        "Moderator"
      else
        "Coach"
      end
    end
  end
end
