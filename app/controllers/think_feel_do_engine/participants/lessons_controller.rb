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
        arm = current_participant.active_membership.group.arm
        learn_tool = arm.bit_core_tools.find_by_type("Tools::Learn")

        redirect_to(
          navigator_context_url(arm_id: arm.id, context_name: learn_tool.title),
          alert: "Lesson not found"
        )
      end
    end
  end
end
