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
    end
  end

  private

  def authorize_admin
    can :manage, :all
  end

  def authorize_coach
    authorize_coach_messaging
    can :update, Membership do |membership|
      CoachAssignment.exists?(
        coach_id: @user.id,
        participant_id: membership.participant_id
      )
    end
    can :manage, PhqAssessment do |assessment|
      CoachAssignment.exists?(
        coach_id: @user.id,
        participant_id: assessment.participant_id
      )
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
  end
end
