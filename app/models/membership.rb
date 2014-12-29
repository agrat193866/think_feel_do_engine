# The relationship of a Participant to a Group.
class Membership < ActiveRecord::Base
  AMERICAN_DATE_RE = %r(^\d\d?\/\d\d?\/\d{2,4}$)
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
  has_many :tasks, through: :task_statuses

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :group, presence: true
  validates :participant, presence: true
  validates :group_id, uniqueness: { scope: :participant_id }
  validate :single_active_membership

  attr_writer :start_date_american, :end_date_american

  delegate :email, to: :participant, prefix: true, allow_nil: true

  before_validation :normalize_dates
  after_create :create_task_statuses

  scope :active, lambda {
    where("start_date <= ? OR start_date = ?", Date.current, nil)
    .where("end_date >= ? OR end_date = ?", Date.current, nil)
  }

  def available_task_statuses
    task_statuses
      .joins(:task, task: :bit_core_content_module)
      .by_position
      .where("start_day <= ?", day_in_study)
      .where("tasks.termination_day >= ? OR tasks.termination_day IS NULL",
             day_in_study)
  end

  def incomplete_tasks
    available_task_statuses
      .where("completed_at IS NULL AND start_day <= ?", day_in_study)
  end

  def incomplete_tasks_today
    available_task_statuses
      .where("completed_at IS NULL AND start_day = ?", day_in_study)
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
    tasks
      .joins(:bit_core_content_module)
      .where("bit_core_content_modules.type = ?",
             "ContentModules::LessonModule")
  end

  private

  def normalize_dates
    self.start_date = parse_american_date(@start_date_american, start_date)
    self.end_date = parse_american_date(@end_date_american, end_date)
  end

  # Parse dates matching [M]M/[D]D/[YY]YY and return ISO8601: YYYY-MM-DD.
  def parse_american_date(date, default)
    parsed = default

    if date.respond_to?(:match) && date.match(AMERICAN_DATE_RE)
      parts = date.split("/")
      year = parts[2].length == 2 ? "20#{ parts[2] }" : parts[2]
      parsed = [year, parts[0], parts[1]].join("-")
    end

    parsed
  end

  def create_task_statuses
    group.tasks.each do |task|
      task.send(:create_recurring_task_statuses, self)
    end
  end

  def single_active_membership
    if Membership.where(participant_id: participant_id)
                 .where("start_date <= ? AND end_date >= ?",
                        end_date, start_date)
                 .where.not(id: id)
                 .exists?
      errors.add(:base, "There can be only one active membership")
    end
  end
end
