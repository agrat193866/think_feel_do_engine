module ThinkFeelDoEngine
  module Participants
    # Manage Participant Activities.
    class ActivitiesController < ApplicationController
      before_action :authenticate_participant!

      def create
        @activity = current_participant.activities.find(activity_id)
        @activity.update(activity_params)
      end

      private

      def activity_id
        params[:activities][:commit_id].keys.first || -1
      end

      def activity_params
        params.require(:activities)
          .permit(activity_id => [
            :actual_pleasure_intensity,
            :actual_accomplishment_intensity
          ])
          .fetch(activity_id)
      end
    end
  end
end
