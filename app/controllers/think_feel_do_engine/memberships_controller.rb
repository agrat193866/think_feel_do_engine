module ThinkFeelDoEngine
  # Allows a clinician to END a participant's study
  class MembershipsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def update
      if ((membership_params[:end_date].to_date) > Date.today) &&
         @membership.update(membership_params)
        flash[:notice] = "Membership successfully updated"
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      else
        flash[:alert] = "Unable to save membership changes. End date cannot "\
        " be set prior to tomorrow's date. Please use [Discontinue] or "\
        "[Terminate Access]."
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      end
    end

    def withdraw
      @membership = Membership.find(end_params[:id])
      if @membership.update(end_date: Date.current - 1)
        flash[:notice] = "Membership successfully withdrawn"
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      else
        flash[:alert] = @membership.errors.full_messages.to_sentence
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      end
    end

    def discontinue
      @membership = Membership.find(end_params[:id])
      if @membership.update(end_date: Date.current - 1, is_complete: true)
        flash[:notice] = "Membership successfully ended"
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      else
        flash[:alert] = @membership.errors.full_messages.to_sentence
        redirect_to coach_group_patient_dashboards_path(@membership.group)
      end
    end

    private

    def end_params
      params.permit :id
    end

    def membership_params
      params
        .require(:membership)
        .permit(:end_date)
    end

    def record_not_found
      flash.now[:alert] = "Unable to find membership"
    end
  end
end
