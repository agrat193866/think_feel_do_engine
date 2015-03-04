# Gives participants notifications on what needs to be completed
class Task < ActiveRecord::Base
  belongs_to :group
  belongs_to :bit_core_content_module, class_name: "BitCore::ContentModule"
  belongs_to :creator, class_name: "User"
  has_many :memberships, through: :group
  has_many :task_statuses, dependent: :destroy

  validates :is_recurring, inclusion: { in: [true, false] }
  validates :release_day,
            uniqueness: {
              scope: [:bit_core_content_module, :group],
              message: "This task has already been assigned and set to be " \
                       "released on this day to this group."
            },
            presence: true

  delegate :title, to: :bit_core_content_module, prefix: false, allow_nil: true
  accepts_nested_attributes_for :task_statuses

  before_save :check_if_valid_release_day
  after_create :assign_task_status_to_each_participant

  scope :learning, lambda {
    joins(:bit_core_content_module)
      .where(
        Arel::Table.new(:bit_core_content_modules)[:type]
        .eq("ContentModules::LessonModule")
      )
  }

  def incomplete_participant_list
    task_statuses.collect do |status|
      if status.completed_at.nil?
        status.participant
      end
    end
  end

  def complete_participant_list
    task_statuses.collect do |status|
      unless status.completed_at.nil?
        status.participant
      end
    end
  end

  # Returns a count of the number of times this task was assigned.
  def total_assigned
    task_statuses.count
  end

  # Returns the count of the number of times this task was completed.
  def total_read
    task_statuses.where.not(completed_at: nil).count
  end

  private

  def check_if_valid_release_day
    if group.memberships.any? { |m| release_day > m.length_of_study }
      errors.add :base, "Release day comes after some members are finished"

      false
    else
      true
    end
  end

  def assign_task_status_to_each_participant
    group.memberships.each do |membership|
      create_recurring_task_statuses(membership)
    end
  end

  def create_recurring_task_statuses(membership)
    if is_recurring
      i = release_day
      end_day = termination_day ? termination_day : membership.length_of_study
      while i <= end_day
        create_task(membership.id, i)
        i += 1
      end
    else
      create_task(membership.id)
    end
  end

  def create_task(membership_id, day = nil)
    day ||= release_day
    TaskStatus.create!(
      membership_id: membership_id,
      start_day: day,
      task_id: id)
  end
end
