# Holds the completion status of a task for each participant
class TaskStatus < ActiveRecord::Base
  belongs_to :membership
  belongs_to :task
  has_one :participant, through: :membership
  has_many :engagements, dependent: :destroy

  delegate :bit_core_content_module,
           :bit_core_content_module_id,
           :release_day,
           :title,
           to: :task
  delegate :participant_id, to: :membership, prefix: false

  scope :for_content_module, lambda { |content_module|
    joins(:task)
      .where(tasks: { bit_core_content_module_id: content_module.id })
  }

  scope :for_content_module_ids, lambda { |ids|
    joins(:task)
      .where(tasks: { bit_core_content_module_id: ids })
  }

  # To Do: should this be renamed or removed?
  # Is this being used anymore?
  scope :available_for_learning, lambda { |membership|
    joins(:task, task: :bit_core_content_module)
      .by_position
      .where(
        arel_table[:start_day]
        .lteq(membership.day_in_study)
      )
  }

  scope :completed, -> { where(arel_table[:completed_at].not_eq(nil)) }

  scope :incomplete, -> { where(arel_table[:completed_at].eq(nil)) }

  scope :by_position, lambda {
    joins(:task, task: :bit_core_content_module)
      .order("bit_core_content_modules.position ASC")
  }

  scope :available_by_day, lambda { |day_in_study|
    where(arel_table[:start_day].lteq(day_in_study))
  }

  scope :incomplete_by_day, lambda { |day_in_study|
    where(arel_table[:start_day].lteq(day_in_study))
      .incomplete
  }

  scope :incomplete_on_day, lambda { |day_in_study|
    where(arel_table[:start_day].eq(day_in_study))
      .incomplete
  }

  scope :not_terminated_by_day, lambda { |day_in_study|
    tasks = Arel::Table.new(:tasks)
    joins(:task)
      .where(
        tasks[:termination_day].eq(nil)
        .or(
          tasks[:termination_day].gteq(day_in_study)
        )
      )
  }

  def provider_viz?
    try(:bit_core_content_module).try(:is_viz)
  end

  def mark_complete
    if completed_at
      save!
    else
      update_attributes(completed_at: DateTime.current)
    end
  end

  def is_lesson?
    task.bit_core_content_module.type == "ContentModules::LessonModule"
  end

  def notify_today?
    today = Time.now
    start_day == ((today.to_date - membership.start_date.to_date).to_i + 1)
  end

  def available_for_learning_on
    membership.start_date + release_day - 1
  end
end
