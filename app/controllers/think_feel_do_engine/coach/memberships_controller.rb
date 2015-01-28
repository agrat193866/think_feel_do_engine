module ThinkFeelDoEngine
  module Coach
    # Manage Participant Activities.
    class MembershipsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_membership, :set_group

      def update
        authorize! :update, @membership
        if @membership.update(membership_params)
          redirect_to coach_group_patient_dashboards_path(@group),
                      notice: "Participant was successfully stepped."
        else
          redirect_to coach_group_patient_dashboards_path(@group),
                      alert: @membership.errors.full_messages.join(", ")
        end
      end

      private

      def membership_params
        params
          .require(:membership)
          .permit(:is_stepped)
      end

      def set_group
        @group = Group.find(params[:group_id])
      end

      def set_membership
        @membership = Membership.find(params[:id])
      end
    end
  end
end
