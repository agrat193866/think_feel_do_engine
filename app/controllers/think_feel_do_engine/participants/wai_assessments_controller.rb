module ThinkFeelDoEngine
  module Participants
    # Authorizes and manages WaiAssessment administration.
    class WaiAssessmentsController < ApplicationController
      before_action :authorize_token

      def new
        @wai_assessment = @participant.build_wai_assessment(
          release_date: @token.release_date
        )
      end

      def create
        @wai_assessment = @participant.build_wai_assessment(assessment_params)

        if @wai_assessment.save
          flash.now[:notice] = "Assessment saved"
          render :success
        else
          errors = @wai_assessment.errors.full_messages.join(", ")
          flash.now[:alert] = "Unable to save assessment: #{ errors }"
          render :new
        end
      end

      private

      def authorize_token
        token_params = (params[:wai_assessment] || {})[:token]
        @token = ParticipantToken.find_by_token(token_params)

        if @token
          @participant = Participant.find(@token.participant_id)
        else
          redirect_to main_app.root_url, alert: "Sorry, that link was invalid"
        end
      end

      def assessment_params
        params
          .require(:wai_assessment)
          .permit(:q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9)
          .merge(release_date: @token.release_date)
      end
    end
  end
end
