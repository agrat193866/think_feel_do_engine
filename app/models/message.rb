# A message sent from a Participant or User to a Participant or User.
class Message < ActiveRecord::Base
  include ThinkFeelDoEngine::Addressable

  belongs_to :sender, polymorphic: true
  belongs_to :recipient, polymorphic: true
  has_many :delivered_messages, dependent: :destroy

  validates :subject, :sender, :recipient, presence: true
  validate :participant_is_messageable,
           if: proc { |message| message.recipient.try(:notify_by_email?) }

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

  private

  def create_delivered_messages
    recipient.received_messages.create(message_id: id)
  end

  def messaging_tool
    recipient
      .current_group
      .arm
      .bit_core_tools
      .find_by_type("Tools::Messages")
  end

  def participant_is_messageable
    unless messaging_tool
      errors
        .add :base, "We're sorry, but this participant does"\
                    " not have access to the messaging tool."
    end
  end

  def populate_sent_at
    self.sent_at = Time.new
  end
end
