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

  validates :arm_id, presence: true
  validates :title, presence: true, length: { maximum: 50 }

  delegate :count, to: :memberships, prefix: true

  def learning_tasks
    tasks
      .joins(:bit_core_content_module)
      .where(
        Arel::Table.new(:bit_core_content_modules)[:type]
        .eq("ContentModules::LessonModule")
      )
  end

  def logins_by_week(week_number)
    login_count = 0
    self.memberships.each do |membership|
      login_count +=
        membership
          .participant
          .participant_login_events
          .where("created_at >= ? AND created_at < ?",
            week_start_day(week_number), week_end_day(week_number))
          .count
    end
    login_count
  end

  def thoughts_by_week(week_number)
    thought_count = 0
    self.memberships.each do |membership|
      thought_count +=
        membership
          .participant
          .thoughts
          .where("created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    thought_count
  end

  def activities_planned_by_week(week_number)
    activities_count = 0
    self.memberships.each do |membership|
      activities_count +=
        membership
          .participant
          .activities
          .where("is_scheduled = true AND created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    activities_count
  end

  def activities_monitored_by_week(week_number)
    activities_count = 0
    self.memberships.each do |membership|
      activities_count +=
        membership
          .participant
          .activities
          .where("is_monitored = true AND created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    activities_count
  end

  def activities_reviewed_by_week(week_number)
    activities_count = 0
    self.memberships.each do |membership|
      activities_count +=
        membership
          .participant
          .activities
          .where("is_complete = true AND created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    activities_count
  end

  def goals_by_week(week_number)
    goal_count = 0
    self.memberships.each do |membership|
      goal_count +=
        SocialNetworking::Goal
          .where(participant: membership.participant)
          .where("created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    goal_count
  end

  def comments_by_week(week_number)
    comments_count = 0
    self.memberships.each do |membership|
      comments_count +=
        SocialNetworking::Comment
          .where(participant: membership.participant)
          .where("created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    comments_count
  end

  def on_the_mind_statements_by_week(week_number)
    on_the_mind_statements_count = 0
    self.memberships.each do |membership|
      on_the_mind_statements_count +=
        SocialNetworking::OnTheMindStatement
          .where(participant: membership.participant)
          .where("created_at >= ? AND created_at < ?",
            week_start_day(week_number), week_end_day(week_number))
          .count
    end
    on_the_mind_statements_count
  end

  def likes_by_week(week_number)
    likes_statements_count = 0
    self.memberships.each do |membership|
      likes_statements_count +=
        SocialNetworking::Like
          .where(participant: membership.participant)
          .where("created_at >= ? AND created_at < ?",
                 week_start_day(week_number), week_end_day(week_number))
          .count
    end
    likes_statements_count
  end

  private

  # Returns the earliest start date of all the group's memberships
  def start_date
    self.memberships.order(start_date: :asc).first.start_date
  end

  def week_start_day(week_number)
    start_date + ((week_number - 1) * 7).days
  end

  def week_end_day(week_number)
    start_date + (week_number * 7).days
  end
end
