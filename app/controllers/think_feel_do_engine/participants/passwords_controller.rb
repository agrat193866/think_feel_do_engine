module ThinkFeelDoEngine
  module Participants
    # Customize User password actions.
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
          super
        end
      end
    end
  end
end
