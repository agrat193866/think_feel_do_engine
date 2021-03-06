# Uses CanCan to assign granular authorizations.
class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest user by default
    @user = user || User.new

    if @user.admin?
      authorize_admin
    else
      authorize_coach if @user.coach?
      authorize_content_author if @user.content_author?
      authorize_researcher if @user.researcher?
    end
  end

  private

  def authorize_admin
    can :manage, :all
  end

  def authorize_coach
    can :index, Arm
    can :show, Arm do |arm|
      # TODO: make a nicer scope/sql call
      access = false
      arm.groups.each do |group|
        unless access
          access = !(group.participant_ids & @user.participant_ids).empty?
        end
      end
      access
    end
    can [:show, :moderate], Group do |group|
      !(@user.participant_ids & group.participant_ids).empty?
    end
    can :show, Participant do |participant|
      @user.participant_ids.include?(participant.id)
    end
    authorize_coach_messaging
    can [:withdraw, :discontinue, :update], Membership do |membership|
      coach_has_participant? @user.id, membership.participant_id
    end
    can :manage, PhqAssessment do |assessment|
      coach_has_participant? @user.id, assessment.participant_id
    end
  end

  def authorize_coach_messaging
    can [:create, :index], Message
    can :show, Message do |message|
      (message.try(:sender) == @user) || (message.try(:recipient) == @user)
    end
    can(:show, DeliveredMessage) do |message|
      message.try(:recipient) == @user
    end
    can [:new, :index], SiteMessage
    can [:create, :show], SiteMessage do |message|
      coach_has_participant? @user.id, message.participant_id
    end
  end

  def coach_has_participant?(coach_id, participant_id)
    CoachAssignment.exists?(
      coach_id: coach_id,
      participant_id: participant_id
    )
  end

  # think_feel_do_engine
  def authorize_content_author
    can :read, Arm
    can :update, Group
    can :manage, BitCore::ContentModule
    can :manage, BitCore::ContentProvider
    can :manage, BitCore::Slideshow
    can :manage, BitCore::Slide
  end

  # think_feel_do_dashboard
  def authorize_researcher
    can [:show, :index], Arm
    [Group, CoachAssignment, Membership, Participant, Task, User]
      .each do |klass|
      can :manage, klass
    end
    can :read, "Reports"
  end
end
