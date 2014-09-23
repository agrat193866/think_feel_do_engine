module ThinkFeelDoEngine
  # Enables Membership CRUD functionality.
  class MembershipsController < ApplicationController
    before_action :authenticate_user!
    layout "manage"

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def update
      @membership = Membership.find(params[:id])
      authorize! :update, @membership

      if @membership.update(membership_params)
        flash.now[:notice] = "Membership successfully updated"
      else
        flash.now[:alert] = "There were errors"
      end
    end

    private

    def record_not_found
      flash.now[:alert] = "Unable to find membership"
    end

    def membership_params
      params.require(:membership).permit(:end_date)
    end
  end
end
