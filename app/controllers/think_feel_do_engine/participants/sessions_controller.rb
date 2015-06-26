module ThinkFeelDoEngine
  module Participants
    # Extends the Devise controller to record logins.
    class SessionsController < Devise::SessionsController
      layout "application"

      skip_authorization_check

      def create
        super do |resource|
          ParticipantLoginEvent.create(participant_id: resource.id)
        end
      end
    end
  end
end
