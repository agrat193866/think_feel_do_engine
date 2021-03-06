# The relationship of a Participant to a Group.
class Membership < ActiveRecord::Base
  AMERICAN_DATE_FMT = "%m/%d/%Y"

  belongs_to :group
  belongs_to :active_group,
             class_name: "Group",
             foreign_key: :group_id,
             inverse_of: :active_memberships
  belongs_to :participant
  belongs_to :active_participant,
             class_name: "Participant",
             foreign_key: :participant_id,
             inverse_of: :active_membership
  has_many :task_statuses, dependent: :destroy
  has_many :tasks,
           -> { uniq },
           through: :task_statuses

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :group, presence: true
  validates :participant, presence: true
  validates :group_id, uniqueness: { scope: :participant_id }
  validate :not_complete_in_the_future
  validate :group_id_unchanged
  validate :single_active_membership
  validate :not_ending_in_the_past

  delegate :email, to: :participant, prefix: true, allow_nil: true

  after_create :create_task_statuses

  scope :active, lambda {
    where(
      arel_table[:start_date].lteq(Date.current)
      .and(arel_table[:end_date].gteq(Date.current))
      .or(arel_table[:is_complete].eq(true))
    )
  }

  scope :inactive, lambda {
    where(
      arel_table[:start_date].gt(Date.current)
      .or(arel_table[:end_date].lt(Date.current))
    )
  }

  scope :continuing, lambda {
    where(is_complete: false)
  }

  def available_task_statuses
    @available_task_statuses ||=
      task_statuses
      .available_by_day(day_in_study)
      .not_terminated_by_day(day_in_study)
      .joins(:task, task: :bit_core_content_module)
      .by_position
  end

  def incomplete_tasks
    available_task_statuses
      .incomplete_by_day(day_in_study)
  end

  def incomplete_tasks_today
    available_task_statuses
      .incomplete_on_day(day_in_study)
  end

  def week_in_study(date = nil)
    (day_in_study(date) / 7.0).ceil == 0 ? 1 : (day_in_study(date) / 7.0).ceil
  end

  def day_in_study(date = nil)
    ((date || Date.current) - start_date).to_i + 1
  end

  def length_of_study
    end_date - start_date + 1
  end

  def start_date_american
    start_date && start_date.strftime(AMERICAN_DATE_FMT)
  end

  def end_date_american
    end_date && end_date.strftime(AMERICAN_DATE_FMT)
  end

  def learning_tasks
    tasks.learning
  end

  def flag_complete
    self.is_complete = true
    self.end_date = Date.yesterday

    save validate: false
  end

  def logins_by_week(week_number)
    participant_login_events = Arel::Table.new(:participant_login_events)
    participant
      .participant_login_events
      .where(participant_login_events[:created_at]
               .gteq(week_start_day(week_number)))
      .where(participant_login_events[:created_at]
               .lt(week_end_day(week_number)))
      .count
  end

  def logins_today
    participant_login_events = Arel::Table.new(:participant_login_events)
    participant
      .participant_login_events
      .where(participant_login_events[:created_at]
                 .gteq(Date.current.beginning_of_day))
      .where(participant_login_events[:created_at]
                 .lt(Date.current.end_of_day))
  end

  def lessons_read
    task_statuses.completed.select(&:is_lesson?)
  end

  def lessons_read_for_day(time)
    task_statuses
      .completed
      .where("completed_at <= ? AND completed_at >= ?",
             time.end_of_day,
             time.beginning_of_day)
      .select(&:is_lesson?)
  end

  def lessons_read_for_week
    task_statuses
      .completed
      .where("completed_at >= ?", Time.current.advance(days: -7)
                                      .beginning_of_day)
      .select(&:is_lesson?)
  end

  def withdraw
    return false unless valid?

    update_column(:end_date, Date.current - 1.day)
  end

  def discontinue
    return false unless valid?

    update_columns(end_date: Date.current - 1.day, is_complete: true)
  end

  private

  def create_task_statuses
    group.tasks.each do |task|
      task.send(:create_recurring_task_statuses, self)
    end
  end

  def single_active_membership
    if Membership.where(participant_id: participant_id)
       .where("start_date <= ? AND end_date >= ?", end_date, start_date)
       .where.not(id: id)
       .exists?
      errors.add(:base, "There can be only one active membership")
    end
  end

  def group_id_unchanged
    if changed.include?("group_id") && !changes["group_id"][0].nil?
      errors.add :group_id, "cannot be changed"
    end
  end

  def not_complete_in_the_future
    return unless end_date && end_date > Date.today && is_complete == true

    errors.add :is_complete, "cannot be set to true for end dates in the future"
  end

  def week_start_day(week_number)
    start_date + ((week_number - 1) * 7).days
  end

  def week_end_day(week_number)
    start_date + (week_number * 7).days
  end

  def not_ending_in_the_past
    return unless end_date && end_date_changed? && end_date < Date.current

    errors.add :end_date, "must not be in the past"
  end
end
