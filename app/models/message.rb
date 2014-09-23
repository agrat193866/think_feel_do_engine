# A message sent from a Participant or User to a Participant or User.
class Message < ActiveRecord::Base
  belongs_to :sender, polymorphic: true
  belongs_to :recipient, polymorphic: true
  has_many :delivered_messages, dependent: :destroy

  validates :subject, :sender, :recipient, presence: true

  before_create :populate_sent_at
  after_create :create_delivered_messages

  delegate :email, :study_id, to: :recipient, prefix: true, allow_nil: true

  def render_body
    rendered = ""

    unless body.nil?
      markdown = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,
        space_after_headers: true
      )

      rendered += markdown.render(body)
    end

    rendered.html_safe
  end

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

  private

  def populate_sent_at
    self.sent_at = Time.new
  end

  def create_delivered_messages
    recipient.received_messages.create(message_id: id)
  end
end
