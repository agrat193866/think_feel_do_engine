module ThinkFeelDoEngine
  module Coach
    # Enables viewing of messages sent to coaches.
    class ReceivedMessagesController < ApplicationController
      before_action :authenticate_user!, :set_group

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      layout "manage"

      def show
        @received_message = current_user.received_messages.find(params[:id])
        authorize! :show, @received_message
        @received_message.try(:mark_read)
        render(
          template: "think_feel_do_engine/messages/show",
          locals: {
            message: @received_message,
            compose_path: new_coach_group_message_path(@group),
            reply_path: reply_path(@received_message)
          }
        )
      end

      private

      def reply_path(received_message)
        new_coach_group_message_path(
          @group,
          # This Message.class IS DeliveredMessage
          body: "#{received_message.body}",
          message_id: received_message.id,
          recipient_id: received_message.message.sender_id,
          subject: "Reply: #{received_message.subject}"
        )
      end

      def record_not_found
        redirect_to main_app.root_url, alert: "Unable to find message"
      end

      def set_group
        @group = Group.find(params[:group_id])
      end
    end
  end
end
