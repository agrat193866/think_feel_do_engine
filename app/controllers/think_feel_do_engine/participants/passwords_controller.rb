module ThinkFeelDoEngine
  module Participants
    # Customize Participant password actions.
    class PasswordsController < Devise::PasswordsController
      # PUT /resource/password
      def update
        participant = Participant
                      .with_reset_password_token(
                        params[:participant][:reset_password_token]
                      )
        if participant && !participant.active_membership
          msg = "We're sorry, but you can't sign in yet because you are not " \
                "assigned to an active group."
          redirect_to new_participant_session_path, alert: msg
        else
          super do |resource|
            ParticipantLoginEvent.create(participant_id: resource.id)
          end
        end
      end

      def create
        @participant = Participant.find_by(email: resource_params[:email])
        if @participant.try(:is_not_allowed_in_site)
          msg = "New password cannot be sent; this account is not active."
          redirect_to new_participant_session_path, alert: msg
        else
          super
        end
      end
    end
  end
end
