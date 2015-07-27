module ThinkFeelDoEngine
  # Allows a clinician to END a participant's study
  class MembershipsController < ApplicationController
    before_action :authenticate_user!, :load_and_authorize_update!

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def update
      if @membership.update(membership_params)
        flash[:notice] = "Membership successfully updated"
      else
        flash[:alert] = "Unable to save membership changes. End date cannot "\
        " be set prior to tomorrow's date. Please use [Discontinue] or "\
        "[Terminate Access]."
      end

      redirect_to coach_group_patient_dashboards_path(@membership.group)
    end

    def withdraw
      if @membership.withdraw
        flash[:notice] = "Membership successfully withdrawn"
      else
        flash[:alert] = @membership.errors.full_messages.to_sentence
      end

      redirect_to coach_group_patient_dashboards_path(@membership.group)
    end

    def discontinue
      if @membership.discontinue
        flash[:notice] = "Membership successfully ended"
      else
        flash[:alert] = @membership.errors.full_messages.to_sentence
      end

      redirect_to coach_group_patient_dashboards_path(@membership.group)
    end

    private

    def load_and_authorize_update!
      @membership = Membership.find(params[:id])
      authorize! :update, @membership
    end

    def membership_params
      params.require(:membership).permit(:end_date)
    end

    def record_not_found
      flash.now[:alert] = "Unable to find membership"
    end
  end
end
