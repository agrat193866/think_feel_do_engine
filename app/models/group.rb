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
  validates :title, presence: true, length: { maximum: 50 }, uniqueness: true

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
    participant_login_events = Arel::Table.new(:participant_login_events)

    memberships.map do |membership|
      membership
        .participant
        .participant_login_events
        .where(participant_login_events[:created_at]
                 .gteq(week_start_day(week_number)))
        .where(participant_login_events[:created_at]
                 .lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def thoughts_by_week(week_number)
    thoughts = Arel::Table.new(:thoughts)

    memberships.map do |membership|
      membership
        .participant
        .thoughts
        .where(thoughts[:created_at].gteq(week_start_day(week_number)))
        .where(thoughts[:created_at].lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def activities_past_by_week(week_number)
    activities = Arel::Table.new(:activities)

    memberships.map do |membership|
      membership
        .participant
        .activities
        .in_the_past
        .where(activities[:created_at].gteq(week_start_day(week_number)))
        .where(activities[:created_at].lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def activities_future_by_week(week_number)
    activities = Arel::Table.new(:activities)

    memberships.map do |membership|
      membership
        .participant
        .activities
        .unscheduled_or_in_the_future
        .where(activities[:created_at].gteq(week_start_day(week_number)))
        .where(activities[:created_at].lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def goals_by_week(week_number)
    social_networking_goals = Arel::Table.new(:social_networking_goals)

    memberships.map do |membership|
      SocialNetworking::Goal
        .where(participant: membership.participant)
        .where(social_networking_goals[:created_at]
                 .gteq(week_start_day(week_number)))
        .where(social_networking_goals[:created_at]
                 .lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def comments_by_week(week_number)
    social_networking_comments = Arel::Table.new(:social_networking_comments)

    memberships.map do |membership|
      SocialNetworking::Comment
        .where(participant: membership.participant)
        .where(social_networking_comments[:created_at]
                 .gteq(week_start_day(week_number)))
        .where(social_networking_comments[:created_at]
                 .lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def on_the_mind_statements_by_week(week_number)
    social_networking_on_the_mind_statements =
      Arel::Table.new(:social_networking_on_the_mind_statements)

    memberships.map do |membership|
      SocialNetworking::OnTheMindStatement
        .where(participant: membership.participant)
        .where(social_networking_on_the_mind_statements[:created_at]
                 .gteq(week_start_day(week_number)))
        .where(social_networking_on_the_mind_statements[:created_at]
                 .lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  def likes_by_week(week_number)
    social_networking_likes =
      Arel::Table.new(:social_networking_likes)

    memberships.map do |membership|
      SocialNetworking::Like
        .where(participant: membership.participant)
        .where(social_networking_likes[:created_at]
                 .gteq(week_start_day(week_number)))
        .where(social_networking_likes[:created_at]
                 .lt(week_end_day(week_number)))
    end.map(&:count).sum
  end

  private

  # Returns the earliest start date of all the group's memberships
  def start_date
    memberships.order(start_date: :asc).first.start_date
  end

  def week_start_day(week_number)
    start_date + ((week_number - 1) * 7).days
  end

  def week_end_day(week_number)
    start_date + (week_number * 7).days
  end
end
