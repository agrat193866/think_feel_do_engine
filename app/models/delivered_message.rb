# An instance of a Message sent to a Participant or User.
class DeliveredMessage < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient, polymorphic: true

  validates :message, :recipient, presence: true
  validates :is_read, inclusion: { in: [true, false] }

  after_create :deliver_notifications

  scope :unread, -> { where(is_read: false) }

  scope :sent_from, lambda { |sender_id|
    joins(:message)
      .where("messages.sender_id = ?", sender_id)
  }

  delegate :body, :render_body, :sender, :subject, to: :message

  def from(user)
    if sender.id == user.id
      "You"
    else
      sender.try(:study_id) ? sender.study_id : "Coach"
    end
  end

  def to(user)
    if recipient_id == user.id
      "You"
    else
      recipient.try(:study_id) ? recipient.study_id : "Coach"
    end
  end

  def mark_read
    update(is_read: true)
  end

  private

  def deliver_notifications
    if recipient.instance_of? User
      ThinkFeelDoEngine::MessageNotifications
        .new_for_coach(recipient, group)
        .deliver
    elsif recipient.notify_by_sms?
      MessageSmsNotification.deliver_to(recipient)
    else
      ThinkFeelDoEngine::MessageNotifications
        .new_for_participant(recipient, group)
        .deliver
    end
  rescue
    # swallow exception
  end
end
