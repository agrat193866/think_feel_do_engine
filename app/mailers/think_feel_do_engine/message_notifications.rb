module ThinkFeelDoEngine
  # Mailer for notifying of new application messages.
  class MessageNotifications < ActionMailer::Base
    default from: "stepped_care-no-reply@northwestern.edu"

    def new_for_coach(coach)
      mail to:      coach.email,
           subject: "New message"
    end

    def new_for_participant(participant)
      mail to:      participant.email,
           subject: "New message"
    end
  end
end
