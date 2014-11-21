module ThinkFeelDoEngine
  class ArmsController < ApplicationController
    before_action :authenticate_user!

    layout "manage"

    # GET /arms
    def index
      @arms = Arm.all
    end

    # GET /arms/:id
    def show
      @arm = Arm.find(params[:id])
    end
  end
end
