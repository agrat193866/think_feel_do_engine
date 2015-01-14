module ThinkFeelDoEngine
  module Participants
    # Read Lesson content.
    class LessonsController < ApplicationController
      before_action :authenticate_participant!

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      layout "tool"

      def show
        @lesson = ContentModules::LessonModule.find(params[:id])
      end

      private

      def record_not_found
        arm_id = current_participant.active_membership.group.arm_id

        redirect_to(
          navigator_context_url(arm_id: arm_id, context_name: "LEARN"),
          alert: "Lesson not found"
        )
      end
    end
  end
end
