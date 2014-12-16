# SMS notification service for Messages sent to Participants.
class MessageSmsNotification
  def self.messages
    @messages ||= []
  end

  def self.deliver_to(recipient)
    from = "#{ Rails.application.config.try(:twilio_account_telephone_number) }"
    message = {
      from: from,
      to: "+#{ recipient.phone_number }",
      body: "You have a new ThinkFeelDo message."
    }
    deliver message
  end

  def self.deliver(message)
    if Rails.env.staging? || Rails.env.production?
      client = Twilio::REST::Client.new(
        Rails.application.config.twilio_account_sid,
        Rails.application.config.twilio_auth_token
      )

      client.account.messages.create message
    else
      messages << message
    end
  end
end
