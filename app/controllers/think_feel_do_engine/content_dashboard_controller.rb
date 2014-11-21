module ThinkFeelDoEngine
  class ContentDashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      @arm = Arm.find(params[:arm_id])
    end
  end
end
