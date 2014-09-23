module ThinkFeelDoEngine
  module Coach
    # Manages the Participant dashboard for Coaches.
    class PatientDashboardsController < ApplicationController
      before_action :authenticate_user!

      layout "manage"

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def index
        @patients = participants
      end

      def show
        @patient = participants.find(params[:id])
        learning_modules = ContentModules::LessonModule.all
        @learning_tasks = @patient.learning_tasks(learning_modules)
      end

      private

      def coach
        current_user
      end

      def participants
        coach.participants
      end

      def record_not_found
        redirect_to coach_patient_dashboards_url, alert: "Patient not found"
      end
    end
  end
end
