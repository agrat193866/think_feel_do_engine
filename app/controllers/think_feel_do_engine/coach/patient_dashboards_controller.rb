module ThinkFeelDoEngine
  module Coach
    # Manages the Participant dashboard for Coaches.
    class PatientDashboardsController < ApplicationController
      before_action :authenticate_user!, :set_group
      before_action :set_patient, only: :show

      layout "manage"

      def index
        authorize! :show, Participant
        @patients = @group.participants
      end

      def show
        authorize! :show, @patient
        if active_group
          @learning_tasks = @patient.learning_tasks(learning_modules)
        else
          @learning_tasks = []
        end
      end

      private

      def active_group
        @patient.active_group
      end

      def learning_modules
        ContentModules::LessonModule
          .where(
            bit_core_tool_id: tool_ids
          )
      end

      def set_group
        @group = Group.find(params[:group_id])
      end

      def set_patient
        @patient = @group.participants.find(params[:id])
      end

      def tool_ids
        active_group
          .arm
          .bit_core_tools
          .map(&:id)
      end
    end
  end
end
