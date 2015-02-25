module ThinkFeelDoEngine
  module Coach
    # Manages the Group dashboard for Coaches.
    class GroupDashboardController < ApplicationController
      before_action :authenticate_user!, :set_group

      def index
        authorize! :show, @group
      end

      private

      def set_group
        @group = Group.find(params[:group_id])
      end
    end
  end
end