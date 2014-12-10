# A set of Participants.
class Group < ActiveRecord::Base
  belongs_to :arm
  belongs_to :creator, class_name: "User"

  has_many :memberships, dependent: :destroy
  has_many :active_memberships,
           -> { active },
           class_name: "Membership",
           foreign_key: :group_id,
           dependent: :destroy,
           inverse_of: :active_group
  has_many :tasks, dependent: :destroy
  has_many :participants, through: :memberships
  has_many :active_participants, through: :active_memberships

  validates :arm_id, presence: true
  validates :title, presence: true, length: { maximum: 50 }

  delegate :count, to: :memberships, prefix: true

  def learning_tasks
    tasks
      .joins(:bit_core_content_module)
      .where("bit_core_content_modules.type = ?",
             "ContentModules::LessonModule")
  end
end
