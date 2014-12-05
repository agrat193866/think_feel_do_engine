# Uses CanCan to assign granular authorizations.

# To do: move into its own engine... -W
class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest user by default
    @user = user || User.new

    if @user.admin?
      authorize_admin
    elsif @user.coach?
      authorize_coach
    elsif @user.content_author?
      authorize_content_author
    elsif @user.researcher?
      authorize_researcher
    end
  end

  private

  def authorize_admin
    can :manage, :all
  end

  def authorize_coach
    authorize_coach_messaging
    can :update, Membership do |membership|
      coach_has_participant? @user, membership.participant_id
    end
    can :manage, PhqAssessment do |assessment|
      coach_has_participant? @user, assessment.participant_id
    end
  end

  def authorize_coach_messaging
    can :create, Message
    can :read, Message do |message|
      (message.try(:sender) == @user) || (message.try(:recipient) == @user)
    end
    can(:read, DeliveredMessage) do |message|
      message.try(:recipient) == @user
    end
    can :create, SiteMessage do |message|
      coach_has_participant? @user, message.participant_id
    end
  end

  def coach_has_participant?(coach, participant_id)
    CoachAssignment.exists?(
      coach_id: coach.id,
      participant_id: participant_id
    )
  end

  # think_feel_do_dashboard
  def authorize_researcher
    can :manage, CoachAssignment
    can :manage, Group
    can :manage, Membership
    can :manage, ThinkFeelDoDashboard::Moderator
    can :manage, Participant
    can :manage, Reports::LessonSlideView
    can :manage, User
  end

  # think_feel_do_dashboard
  # def authorize_coach
  # end

  # think_feel_do_dashboard
  def authorize_content_author
  end
end
