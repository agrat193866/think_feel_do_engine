module ThinkFeelDoEngine
  module Participants
    # Authorizes and manages Assessment administration.
    class AssessmentsController < ApplicationController
      ASSESSMENT_TYPES = { phq9: PhqAssessment, wai: WaiAssessment }

      before_action :authorize_token

      def new
        @assessment = build_assessment(release_date: @token.release_date)

        render "think_feel_do_engine/participants/assessments/" \
               "new_#{ assessment_name }"
      end

      def create
        @assessment = build_assessment(assessment_params)

        if @assessment.save
          flash.now[:notice] = "Assessment saved"
          render :success
        else
          errors = @assessment.errors.full_messages.join(", ")
          flash.now[:alert] = "Unable to save assessment: #{ errors }"
          render "think_feel_do_engine/participants/assessments/" \
                 "new_#{ assessment_name }"
        end
      end

      private

      def authorize_token
        if token
          @participant = @token.participant
        else
          redirect_to main_app.root_url, alert: "Sorry, that link was invalid"
        end
      end

      def token
        value = (params[:assessment] || {})[:token]

        @token = ParticipantToken.find_by_token(value)
      end

      def assessment_params
        params
          .require(:assessment)
          .permit(assessment_class::QUESTION_ATTRIBUTES)
          .merge(release_date: @token.release_date)
      end

      def build_assessment(attributes)
        assessment_class.new({ participant_id: @participant.id }
                             .merge(attributes))
      end

      def assessment_name
        assessment_class.to_s.underscore.to_sym
      end

      def assessment_class
        ASSESSMENT_TYPES[@token.token_type.to_sym]
      end
    end
  end
end
