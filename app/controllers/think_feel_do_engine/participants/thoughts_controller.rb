module ThinkFeelDoEngine
  module Participants
    # Manage Participant Thoughts.
    class ThoughtsController < ApplicationController
      before_action :authenticate_participant!

      def create
        @thought = current_participant.thoughts.find(params[:thought][:id])
        @thought.update(thought_params)
      end

      private

      def thought_params
        params.require(:thought).permit(:id, :content, :effect, :pattern_id,
                                        :challenging_thought, :act_as_if)
      end
    end
  end
end
