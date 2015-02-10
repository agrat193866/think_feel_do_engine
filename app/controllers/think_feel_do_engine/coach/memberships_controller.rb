module ThinkFeelDoEngine
  module Coach
    # Manage Participant Activities.
    class MembershipsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_membership, :set_group

      def update
        authorize! :update, @membership
        if has_valid_end_date && @membership.update(membership_params)
          redirect_to coach_group_patient_dashboards_path(@group),
                      notice: "Participant was successfully stepped."
        else
          redirect_to coach_group_patient_dashboards_path(@group),
                      alert: @membership.errors.full_messages.join(", ") +
                        "End date cannot be set prior to tomorrow's date. "\
                        "Please use [Discontinue] or [Terminate Access]."
        end
      end

      private

      def membership_params
        params
          .require(:membership)
          .permit(:stepped_on)
      end

      def set_group
        @group = Group.find(params[:group_id])
      end

      def set_membership
        @membership = Membership.find(params[:id])
      end

      def has_valid_end_date
        (membership_params[:end_date] &&
          (membership_params[:end_date].to_date) > Date.today) ||
          membership_params[:end_date].nil?
      end
    end
  end
end
