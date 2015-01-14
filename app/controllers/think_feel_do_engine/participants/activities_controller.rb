module ThinkFeelDoEngine
  module Participants
    # Manage Participant Activities.
    class ActivitiesController < ApplicationController
      before_action :authenticate_participant!
      before_action :set_activity, only: [:update]

      def update
        if @activity.update(activity_params)
          respond_to do |format|
            format.js {render inline: "Turbolinks.visit(window.location);" }
          end
        else
          flash.now[:alert] = @activity.errors.full_messages.join(", ")
          render :edit
        end
      end

      private

      # def activity_id
      #   params[:activities][:commit_id].keys.first || -1
      # end

      # def activity_params
      #   params.require(:activities)
      #     .permit(activity_id => [
      #       :actual_pleasure_intensity,
      #       :actual_accomplishment_intensity
      #     ])
      #     .fetch(activity_id)
      # end

      def set_activity
        @activity = current_participant
                      .activities
                      .find(params[:id])
      end

      def activity_params
        params
          .require(:activity)
          .permit(
            :actual_pleasure_intensity,
            :actual_accomplishment_intensity
          )
      end
    end
  end
end
