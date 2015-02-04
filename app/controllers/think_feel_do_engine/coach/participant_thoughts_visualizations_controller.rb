module ThinkFeelDoEngine
  module Coach
    # Present Participant Thoughts Visualization to the Coach.
    class ParticipantThoughtsVisualizationsController < ApplicationController
      before_action :authenticate_user!

      def show
        participant = Participant.find(params[:participant_id])
        thoughts = participant.thoughts.harmful
        render "think_feel_do_engine/thoughts/distortion_viz",
               locals: { thoughts: thoughts }
      end
    end
  end
end
