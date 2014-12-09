module ThinkFeelDoEngine
  # Gives users access to filtered groups
  class ArmsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    layout "manage"

    # GET /arms
    def index
    end

    # GET /arms/:id
    def show
    end
  end
end
