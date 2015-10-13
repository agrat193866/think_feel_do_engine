# An instance of a Message sent to a Participant or User.
class DeliveredMessage < ActiveRecord::Base
  include ThinkFeelDoEngine::Addressable

  belongs_to :message
  belongs_to :recipient, polymorphic: true

  validates :message, :recipient, presence: true
  validates :is_read, inclusion: { in: [true, false] }

  after_create :deliver_notifications

  scope :unread, -> { where(is_read: false) }

  scope :sent_from, lambda { |sender_id|
    joins(:message)
      .where(
        Arel::Table.new(:messages)[:sender_id]
        .eq(sender_id)
      )
  }

  delegate :body, :render_body, :sender, :subject, to: :message

  def mark_read
    update(is_read: true)
  end

  private

  def deliver_notifications
    if recipient.instance_of? User
      ThinkFeelDoEngine::MessageNotifications
        .new_for_coach(recipient, sender.active_group)
        .deliver
    elsif recipient.notify_by_sms?
      MessageSmsNotification
        .new(
          body: "You have a new #{application_name} message.",
          phone_number: recipient.phone_number)
        .deliver
    else
      ThinkFeelDoEngine::MessageNotifications
        .new_for_participant(recipient)
        .deliver
    end
  rescue => exception
    ::Raven.capture_message(exception)
  end

  def application_name
    internationalization
      .t(:application_name, default: "ThinkFeelDo")
  end

  def internationalization
    I18n
  end
end
