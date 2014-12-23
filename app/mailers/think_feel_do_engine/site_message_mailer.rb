module ThinkFeelDoEngine
  # Mailer for SiteMessage delivery.
  class SiteMessageMailer < ActionMailer::Base
    def general(message)
      @body = message.body

      mail to: message.participant.email,
           subject: message.subject
    end
  end
end
