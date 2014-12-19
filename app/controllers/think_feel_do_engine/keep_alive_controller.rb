module ThinkFeelDoEngine
  # Authenticate user
  class KeepAliveController < ApplicationController
    before_action :authenticate_participant!

    # GET /arms
    def index
      render nothing: true, status: :ok
    end
  end
end
