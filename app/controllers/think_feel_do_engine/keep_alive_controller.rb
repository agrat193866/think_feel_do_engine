module ThinkFeelDoEngine
  # Authenticate user
  class KeepAliveController < ApplicationController
    before_action :authenticated_participant_or_user?

    # GET /arms
    def index
      if @authenticated
        render nothing: true, status: :ok
      else
        render nothing: true, status: :unauthorized
      end
    end

    private

    def authenticated_participant_or_user?
      if current_user
        authenticate_user!
        @authenticated = true
      elsif current_participant
        authenticate_participant!
        @authenticated = true
      end
    end
  end
end
