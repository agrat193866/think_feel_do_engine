require "strong_password"

# A person enrolled in the intervention.
class Participant < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable, :timeoutable,
         timeout_in: 20.minutes

  has_many :memberships, dependent: :destroy
  has_one :active_membership,
          -> { active },
          class_name: "Membership",
          foreign_key: :participant_id,
          dependent: :destroy,
          inverse_of: :active_participant
  has_many :groups, through: :memberships
  has_one :active_group, through: :active_membership
  has_many :activities, dependent: :destroy
  has_many :awake_periods, dependent: :destroy
  has_many :activity_types, dependent: :destroy
  has_many :emotions, dependent: :destroy, foreign_key: :creator_id
  has_many :emotional_ratings, dependent: :destroy
  has_many :moods, dependent: :destroy
  has_many :thoughts, dependent: :destroy
  has_many :sent_messages, class_name: "Message", as: :sender
  has_many :messages, as: :sender, dependent: :destroy
  has_many :received_messages,
           -> { includes :message },
           class_name: "DeliveredMessage",
           as: :recipient,
           dependent: :destroy
  has_many :phq_assessments, dependent: :destroy
  has_many :participant_tokens, dependent: :destroy
  has_one :participant_status, class_name: "BitPlayer::ParticipantStatus"
  has_one :coach_assignment, dependent: :destroy
  has_one :coach, class_name: "User", through: :coach_assignment
  has_many :participant_login_events, dependent: :destroy
  has_many :events,
           class_name: "EventCapture::Event",
           foreign_key: :participant_id,
           dependent: :destroy
  has_many :click_events,
           -> { where(kind: "click") },
           class_name: "EventCapture::Event",
           foreign_key: :participant_id

  delegate :end_date, to: :active_membership, prefix: true, allow_nil: true

  validates :password,
            password_strength: { use_dictionary: true },
            if: :password_is__not_blank?

  validate :at_least_one_moderator_exists

  accepts_nested_attributes_for :coach_assignment

  def self.active
    joins(:memberships).merge(Membership.active)
  end

  def password_is__not_blank?
    !password.blank?
  end

  def populate_emotions
    %w(Anxious Enthusiastic Grateful Happy Irritable Upset).each do |e|
      emotions.find_or_create_by(name: e)
    end

    emotions
  end

  def unfinished_awake_periods
    # awake periods for which there are no activities with corresponding
    # start_time
    join_sql = <<-SQL
      LEFT JOIN activities
        ON activities.participant_id = awake_periods.participant_id
        AND activities.start_time = awake_periods.start_time
    SQL

    awake_periods.joins(join_sql).where("activities.start_time IS NULL")
  end

  def most_recent_unfinished_awake_period
    unfinished_awake_periods.order("awake_periods.start_time DESC").first
  end

  def build_data_record(association, attributes)
    send(association).build(attributes)
  end

  def build_phq_assessment(attributes)
    phq_assessments.build(attributes)
  end

  def current_group
    membership.group
  end

  def fetch_data_record(association, id)
    send(association).find(id)
  end

  def count_unread_messages
    received_messages.where(is_read: false).count
  end

  def count_all_incomplete(tool)
    return count_unread_messages if tool.title.downcase == "messages"
    content_module_ids = tool.content_modules.includes(:content_providers)
                         .map do |content_module|
                           content_module.id unless content_module
                                                    .try(:content_providers)
                                                    .try(:first)
                                                    .try(:viz?)
                         end

    return false unless content_module_ids
    membership.incomplete_tasks
      .for_content_module_ids(content_module_ids)
      .count
  end

  def count_today_incomplete(tool)
    return count_unread_messages if tool.title.downcase == "messages"
    content_module_ids = tool.content_modules.includes(:content_providers)
                         .map do |content_module|
                           content_module.id unless content_module
                                                    .try(:content_providers)
                                                    .try(:first)
                                                    .try(:viz?)
                         end

    return false unless content_module_ids
    membership.incomplete_tasks_today
      .for_content_module_ids(content_module_ids)
      .count
  end

  def incomplete?(tool)
    # This is usually called to check for "today's" task status
    # Call any_incomplete for things like messages/lessons
    count_today_incomplete(tool) > 0
  end

  def any_incomplete?(tool)
    count_all_incomplete(tool) > 0
  end

  def learning_tasks(content_modules)
    membership.task_statuses
      .for_content_module_ids(content_modules.map(&:id))
  end

  def membership
    @membership ||= memberships.first
  end

  def stepping_suggestion
    data = phq_assessments.map do |x|
      [x.release_date, x] if x.number_answered > 0
    end
    assessment_data = Hash[data]
    PhqStepping.new(
                assessment_data,
                membership.week_in_study
            )
  end

  def navigation_status
    participant_status || build_participant_status
  end

  def recent_accomplished_activities
    recent_activities.accomplished
  end

  def recent_activities
    activities.during(recent_period[:start_time], recent_period[:end_time])
  end

  def recent_pleasurable_activities
    recent_activities.pleasurable
  end

  def flag_inactivity
    participant_login_events
      .order(:created_at)
      .last
      .try(:update_attribute, :inactive_log_out, true)
  end

  # Checks whether the user session has expired based on configured time.
  # Overridden devise method.
  def timedout?(last_access)
    timedout = super
    flag_inactivity if timedout

    timedout
  end

  def unplanned_activities
    UnplannedActivities.new(self)
  end

  def contact_status_enum
    %w(sms email)
  end

  private

  def recent_awake_period
    @recent_awake_period ||= awake_periods.order("start_time").last
  end

  def recent_period
    @recent_period ||= (
      # when no awake period return an empty set to allow chaining
      now = Time.new
      start_time = recent_awake_period.try(:start_time) || now
      end_time = recent_awake_period.try(:end_time) || now

      { start_time: start_time, end_time: end_time }
    )
  end

  def at_least_one_moderator_exists
    if (is_admin == false) && active_group && active_group.active_participants.where(is_admin: true).count == 1
      self.errors.add(:base, "at least one moderator needs to exist.")
    end
  end
end
