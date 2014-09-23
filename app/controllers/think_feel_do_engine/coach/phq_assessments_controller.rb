module ThinkFeelDoEngine
  module Coach
    # Allows a Coach to manage Participants' phq assessments.
    class PhqAssessmentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_participant
      before_action :set_coach_phq_assessment, only: [:edit, :update, :destroy]

      layout "manage"

      # GET /coach/phq_assessments
      def index
        @phq_assessments = @participant.phq_assessments
        authorize! :index, PhqAssessment
      end

      # GET /coach/phq_assessments/new
      def new
        @phq_assessment = @participant.phq_assessments.build
        authorize! :new, @phq_assessment
      end

      # GET /coach/phq_assessments/1/edit
      def edit
        authorize! :edit, @phq_assessment
      end

      # POST /coach/phq_assessments
      def create
        @phq_assessment = @participant
          .phq_assessments.build(coach_phq_assessment_params)
        authorize! :create, @phq_assessment

        if @phq_assessment.save
          redirect_to(
            coach_phq_assessments_url(participant_id: @participant.id),
            notice: "Phq assessment was successfully created."
          )
        else
          render :new
        end
      end

      # PATCH/PUT /coach/phq_assessments/1
      def update
        authorize! :update, @phq_assessment
        if @phq_assessment.update(coach_phq_assessment_params)
          redirect_to(
            coach_phq_assessments_url(participant_id: @participant.id),
            notice: "Phq assessment was successfully updated."
          )
        else
          render :edit
        end
      end

      # DELETE /coach/phq_assessments/1
      def destroy
        authorize! :destroy, @phq_assessment
        @phq_assessment.destroy
        redirect_to(
          coach_phq_assessments_url(participant_id: @participant.id),
          notice: "Phq assessment was successfully destroyed."
        )
      end

      private

      def set_participant
        @participant = Participant.find(params[:participant_id])
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_coach_phq_assessment
        @phq_assessment = @participant.phq_assessments.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def coach_phq_assessment_params
        editor_params = {}

        assessment_params = params.require(:phq_assessment)
          .permit(:release_date, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9)
        [:q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9].each do |q|
          next unless assessment_params[q]
          editor_params[:"#{ q }_editor_id"] = current_user.id
        end

        assessment_params.merge(editor_params)
      end
    end
  end
end
