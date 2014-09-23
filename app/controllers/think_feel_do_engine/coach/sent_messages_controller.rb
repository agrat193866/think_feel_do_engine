module ThinkFeelDoEngine
  module Coach
    # Enables viewing of an individual message sent by coaches.
    class SentMessagesController < ApplicationController
      before_action :authenticate_user!
      layout "manage"

      def show
        @sent_message = current_user.sent_messages.find(params[:id])
        authorize! :read, @sent_message
        render(
          template: "think_feel_do_engine/messages/show",
          locals: {
            message: @sent_message,
            compose_path: new_coach_message_path
          }
        )
      end
    end
  end
end
