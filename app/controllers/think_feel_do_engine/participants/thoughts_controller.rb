module ThinkFeelDoEngine
  module Participants
    # Manage Participant Thoughts.
    class ThoughtsController < ApplicationController
      before_action :authenticate_participant!

      def create
        @thought = current_participant.thoughts.find(thought_id)
        @thought.update(thought_params)
      end

      private

      def thought_id
        params[:thoughts][:commit_id].keys.first || -1
      end

      def thought_params
        params.require(:thoughts)
          .permit(thought_id => [
            :content, :effect, :pattern_id,
            :challenging_thought, :act_as_if
          ])
          .fetch(thought_id)
      end
    end
  end
end
