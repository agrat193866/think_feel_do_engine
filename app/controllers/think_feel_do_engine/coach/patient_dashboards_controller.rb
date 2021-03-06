module ThinkFeelDoEngine
  module Coach
    # Manages the Participant dashboard for Coaches.
    class PatientDashboardsController < ApplicationController
      before_action :authenticate_user!, :set_group
      before_action :set_patient, only: :show

      # rubocop:disable Metrics/LineLength
      def index
        authorize! :show, Participant

        if @group.participants
          if "false" == params[:active]
            @active_patients = false
            @participants = Participant
                            .joins(:memberships)
                            .where("memberships.group_id = ?", @group.id)
                            .inactive
          else
            @active_patients = true
            @participants = Participant
                            .joins(:memberships)
                            .where("memberships.group_id = ? AND " \
                                   "memberships.is_complete = false", @group.id)
                            .active
          end
        end
      end
      # rubocop:enable Metrics/LineLength

      def show
        authorize! :show, @participant
        @lesson_events = ThinkFeelDoEngine::Reports::LessonViewing
                         .all(@participant.id)
      end

      private

      def patient_dashboard_controller_params
        params.permit(:active)
      end

      def active_group
        @participant.active_group
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
        @participant = @group.participants.find(params[:id])
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
