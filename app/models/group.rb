# A set of Participants.
class Group < ActiveRecord::Base
  belongs_to :arm
  belongs_to :creator, class_name: "User"

  has_many :memberships, dependent: :destroy
  has_many :participants, through: :memberships
  has_many :active_memberships,
           -> { active },
           class_name: "Membership",
           foreign_key: :group_id,
           dependent: :destroy,
           inverse_of: :active_group
  has_many :tasks, dependent: :destroy
  has_many :active_participants, through: :active_memberships

  before_validation :create_moderator, on: :create, if: "arm.is_social"

  validates :arm_id, presence: true
  validates :title, presence: true, length: { maximum: 50 }

  delegate :count, to: :memberships, prefix: true

  def moderator
    active_participants.find_by_is_admin(true)
  end

  def learning_tasks
    tasks
      .joins(:bit_core_content_module)
      .where("bit_core_content_modules.type = ?",
             "ContentModules::LessonModule")
  end

  private

  def create_moderator
    unless moderator
      ActiveRecord::Base.transaction do
        password = SecureRandom.hex(64)
        participant = Participant.new(
          display_name: "ThinkFeelDo",
          email: "#{self.title.gsub(' ', '_')}@example.com",
          is_admin: true,
          password: password,
          password_confirmation: password,
          study_id: SecureRandom.hex(64)
        )
        participant.save
        self.memberships.build(
          participant_id: participant.id,
          start_date: Date.today,
          end_date: Date.today.advance(weeks: 8)
        )
      end
    end
  end
end
