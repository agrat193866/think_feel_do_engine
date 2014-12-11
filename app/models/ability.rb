# Uses CanCan to assign granular authorizations.
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
    can :index, Arm
    can :show, Arm do |arm|
      # ToDo: make a nicer scope/sql call
      access = false
      arm.groups.each do |group|
        unless access
          access = !(group.participant_ids & @user.participant_ids).empty?
        end
      end
      access
    end
    can :read, Participant do |participant|
      @user.participant_ids.include?(participant.id)
    end
    can :show, Group do |group|
      !(@user.participant_ids & group.participant_ids).empty?
    end
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
    can :new, SiteMessage
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

  # think_feel_do_engine
  def authorize_content_author
    can :read, Arm
    can :manage, BitCore::ContentModule
    can :manage, BitCore::ContentProvider
    can :manage, BitCore::Slideshow
    can :manage, BitCore::Slide
    can :manage, Group
    can :manage, Task
  end

  # think_feel_do_dashboard
  def authorize_researcher
    can :index, Arm
    can :manage, CoachAssignment
    can :manage, Group
    can :manage, Membership
    can :manage, ThinkFeelDoDashboard::Moderator
    can :manage, Participant
    can :manage, Reports::LessonSlideView
    can :manage, User
  end
end
