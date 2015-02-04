module ThinkFeelDoEngine
  module Coach
    # Enables viewing of an individual message sent by coaches.
    class SentMessagesController < ApplicationController
      before_action :authenticate_user!, :set_group

      def show
        @sent_message = current_user.sent_messages.find(params[:id])
        authorize! :show, @sent_message
        render(
          template: "think_feel_do_engine/messages/show",
          locals: {
            message: @sent_message,
            compose_path: new_coach_group_message_path(@group)
          }
        )
      end

      private

      def set_group
        @group = Group.find(params[:group_id])
      end
    end
  end
end
