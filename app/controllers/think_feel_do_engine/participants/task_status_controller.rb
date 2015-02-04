module ThinkFeelDoEngine
  module Participants
    # Updates the completion of assigned tasks for a participant
    class TaskStatusController < ApplicationController
      before_action :authenticate_participant!

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def update
        @task_status = current_participant
                       .active_membership
                       .task_statuses
                       .find(params[:id])

        if @task_status.engagements.build && @task_status.mark_complete
          render nothing: true, status: 200
        else
          render nothing: true, status: 400
        end
      end

      private

      def record_not_found
        render nothing: true, status: 404
      end
    end
  end
end
