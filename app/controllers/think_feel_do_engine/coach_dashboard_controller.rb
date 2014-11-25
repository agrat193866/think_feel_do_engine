module ThinkFeelDoEngine
  # Enables Coaches to interact with patients via groups
  # by sending messages and composing individual emails.
  class CoachDashboardController < ApplicationController
    before_action :authenticate_user!

    layout "manage"

    def index
    end
  end
end
