module ThinkFeelDoEngine
  module Coach
    # Manages the Participant dashboard for Coaches.
    class PatientDashboardsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_patient, only: :show

      layout "manage"

      def index
        authorize! :show, Participant
        @patients = current_user.participants
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

      def set_patient
        @patient = Participant.find(params[:id])
      end

      def learning_modules
        ContentModules::LessonModule
          .where(
            bit_core_tool_id: tool_ids
          )
      end

      def tool_ids
        active_group
          .arm
          .bit_core_tools
          .map(&:id)
      end

      def active_group
        @patient.active_group
      end
    end
  end
end
