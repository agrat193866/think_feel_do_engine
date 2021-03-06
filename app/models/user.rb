require "devise"

# A person with some authoritative role (a non-Participant).
class User < ActiveRecord::Base
  include ThinkFeelDoEngine::Concerns::ValidatePassword

  devise :database_authenticatable,
         :recoverable, :trackable, :validatable, :timeoutable,
         timeout_in: 20.minutes

  has_many :coach_assignments, foreign_key: :coach_id, dependent: :destroy
  has_many :participants, through: :coach_assignments
  has_many :sent_messages,
           class_name: "Message",
           as: :sender,
           dependent: :destroy
  has_many :tasks, foreign_key: :creator_id, dependent: :nullify
  has_many :messages, as: :sender, dependent: :destroy
  has_many :received_messages,
           -> { includes :message },
           class_name: "DeliveredMessage",
           as: :recipient,
           dependent: :destroy
  has_many :created_groups,
           class_name: "Group",
           foreign_key: :creator_id,
           dependent: :nullify
  has_many :user_roles, dependent: :destroy

  accepts_nested_attributes_for :coach_assignments

  def build_sent_message(attributes = {})
    sent_messages.build(attributes)
  end

  def participants_for_group(group)
    participants.where(id: group.participant_ids)
  end

  def admin?
    is_admin
  end

  def coach?
    user_roles.map(&:role_class_name).include?("Roles::Clinician")
  end

  def researcher?
    user_roles.map(&:role_class_name).include?("Roles::Researcher")
  end

  def content_author?
    user_roles.map(&:role_class_name).include?("Roles::ContentAuthor")
  end
end
