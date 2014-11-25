module ThinkFeelDoEngine
  # Allows users to crud site content (i.e., slideshows
  # and lessons) for groups via arms.
  class ContentDashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      @arm = Arm.find(params[:arm_id])
    end
  end
end
