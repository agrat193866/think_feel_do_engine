# SMS notification service for Messages and Notifications sent to Participants.
class MessageSmsNotification
  attr_reader :body, :phone_number

  def initialize(body:, phone_number:)
    @body = body
    @phone_number = phone_number
  end

  def deliver
    if environment.staging? || environment.production?
      sms_client.account.messages.create message
    else
      message
    end
  end

  private

  def config
    Rails.application.config
  end

  def environment
    Rails.env
  end

  def from_telephone_number
    config.try(:twilio_account_telephone_number)
  end

  def message
    {
      to: "+1#{ phone_number }",
      from: from_telephone_number,
      body: body
    }
  end

  def sms_client
    @sms_client ||= Twilio::REST::Client.new(
      config.twilio_account_sid,
      config.twilio_auth_token)
  end
end
