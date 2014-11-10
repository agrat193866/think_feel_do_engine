module ThinkFeelDoEngine
  # Mailer for SiteMessage delivery.
  class SiteMessageMailer < ActionMailer::Base
    default from: "stepped_care-no-reply@northwestern.edu"

    def general(message)
      @body = message.body

      mail to: message.participant.email,
           subject: message.subject
    end
  end
end
