module ThinkFeelDoEngine
  # Mailer for notifying of new application messages.
  class MessageNotifications < ActionMailer::Base
    def new_for_coach(coach, group)
      @group = group
      mail to:      coach.email,
           subject: "New message"
    end

    def new_for_participant(participant)
      @context_name = participant
                      .current_group
                      .arm
                      .bit_core_tools
                      .find_by_type("Tools::Messages")
                      .title
      mail to:      participant.email,
           subject: "New message"
    end
  end
end
