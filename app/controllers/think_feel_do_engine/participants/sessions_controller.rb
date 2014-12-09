module ThinkFeelDoEngine
  module Participants
    # Extends the Devise controller to record logins.
    class SessionsController < Devise::SessionsController
      skip_authorization_check

      def create
        participant = Participant.find_by_email params[:participant][:email]
        if participant && participant.memberships.count == 0
          msg = "We're sorry, but you can't sign in yet because you are not " \
                "assigned to a group."
          redirect_to new_participant_session_path, alert: msg
        else
          super do |resource|
            ParticipantLoginEvent.create(participant_id: resource.id)
          end
        end
      end
    end
  end
end
