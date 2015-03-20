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
  has_many :activities,
           -> { includes :activity_type },
           dependent: :destroy
  has_many :awake_periods, dependent: :destroy
  has_many :activity_types, dependent: :destroy
  has_many :emotions, dependent: :destroy, foreign_key: :creator_id
  has_many :emotional_ratings,
           -> { includes :emotion },
           dependent: :destroy
  has_many :moods, dependent: :destroy
  has_many :thoughts,
           -> { includes :pattern },
           dependent: :destroy
  has_many :sent_messages, class_name: "Message", as: :sender
  has_many :messages, as: :sender, dependent: :destroy
  has_many :received_messages,
           -> { includes :message },
           class_name: "DeliveredMessage",
           as: :recipient,
           dependent: :destroy
  has_many :addressed_messages,
           class_name: "Message",
           as: :recipient,
           dependent: :destroy
  has_many :phq_assessments, dependent: :destroy
  has_many :wai_assessments, dependent: :destroy
  has_many :participant_tokens, dependent: :destroy
  has_one :participant_status,
          class_name: "BitPlayer::ParticipantStatus",
          dependent: :destroy
  has_one :coach_assignment, dependent: :destroy
  has_one :coach, class_name: "User", through: :coach_assignment
  has_many :participant_login_events, dependent: :destroy
  has_many :media_access_events, dependent: :destroy
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

  accepts_nested_attributes_for :coach_assignment

  def self.active
    joins(:memberships).merge(Membership.active)
  end

  def self.inactive
    joins(:memberships).merge(Membership.inactive)
  end

  scope :stepped, lambda {
    joins(:memberships)
      .where(
        Arel::Table.new(:memberships)[:stepped_on]
        .not_eq(nil)
      )
  }

  scope :not_stepped, lambda {
    joins(:memberships)
      .where(
        Arel::Table.new(:memberships)[:stepped_on]
        .eq(nil)
      )
  }

  def is_not_allowed_in_site
    # participant not set to is_complete (hence withdrawal or termination)
    # and who have no active memberships
    active_membership.nil? && !memberships.where(is_complete: true).exists?
  end

  def active_group_is_social?
    active_group && active_group.arm.social?
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
    active_membership.group
  end

  def fetch_data_record(association, id)
    send(association).find(id)
  end

  def count_unread_messages
    received_messages.where(is_read: false).count
  end

  def count_all_incomplete(tool)
    @count_all_incomplete ||= {}

    @count_all_incomplete[tool.id] ||= (
      if tool.is_a?(Tools::Messages)
        count_unread_messages
      else
        content_module_ids = tool.content_modules.where(is_viz: false)

        if content_module_ids
          active_membership.incomplete_tasks
            .for_content_module_ids(content_module_ids)
            .count
        else
          false
        end
      end
    )
  end

  def learning_tasks(content_modules)
    active_membership.task_statuses
      .for_content_module_ids(content_modules.map(&:id))
  end

  def stepping_suggestion
    data = phq_assessments.map do |x|
      [x.release_date, x] if x.number_answered > 0
    end
    assessment_data = Hash[data]

    PhqStepping.new(assessment_data,
                    active_membership.week_in_study)
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

  def notify_by_email?
    "email" == contact_preference
  end

  def notify_by_sms?
    "sms" == contact_preference || "phone" == contact_preference
  end

  def average_rating(array)
    array.reduce(0) { |a, e| a.to_f + e[0] } / array.size
  end

  def positive_emotions(emotion_array)
    emotions = emotion_array.collect do |emotion|
      if emotion.is_positive
        [emotion.rating, emotion.created_at, emotion.name]
      end
    end
    emotions.compact
  end

  def negative_emotions(emotion_array)
    emotions = emotion_array.collect do |emotion|
      unless emotion.is_positive
        [emotion.rating, emotion.created_at, emotion.name]
      end
    end
    emotions.compact
  end

  def most_recent_membership
    memberships.order(end_date: :desc).first
  end

  def emotional_rating_daily_averages
    averaged_ratings = []

    daily_ratings = emotional_ratings.group_by { |er| er.created_at.to_date }
    # rubocop:disable all
    daily_ratings.each do |day, emotion_array|
    # rubocop:enable all
      positive_ratings = positive_emotions(emotion_array)
      if positive_ratings.size > 0
        daily_positive = { day: day,
                           intensity: average_rating(positive_ratings),
                           is_positive: true,
                           drill_down: positive_ratings,
                           data_type: "Emotion"
                         }
        averaged_ratings << daily_positive
      end
      negative_ratings = negative_emotions(emotion_array)
      if negative_ratings.size > 0
        daily_negative = {  day: day,
                            intensity: average_rating(negative_ratings),
                            is_positive: false,
                            drill_down: negative_ratings,
                            data_type: "Emotion"
                         }
        averaged_ratings << daily_negative
      end
    end
    averaged_ratings
  end

  def in_study?
    if active_membership.start_date <= Date.today &&
       active_membership.end_date >= Date.today
      true
    else
      false
    end
  end

  def mood_rating_daily_averages
    averaged_ratings = []
    daily_ratings = moods.group_by { |mood| mood.created_at.to_date }
    # rubocop:disable all
    daily_ratings.each do |day, moods_array|
    # rubocop:enable all
      ratings = moods_array.collect do |mood|
        [mood.rating, mood.created_at].compact
      end
      if ratings.size > 0
        averaged_ratings << { day: day,
                              intensity: average_rating(ratings),
                              is_positive: true,
                              drill_down: ratings,
                              data_type: "Mood"
                            }
      end
    end
    averaged_ratings
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
end
