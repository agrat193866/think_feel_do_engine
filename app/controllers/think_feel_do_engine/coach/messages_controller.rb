module ThinkFeelDoEngine
  module Coach
    # Manages coach message handling.
    class MessagesController < ApplicationController
      before_action :authenticate_user!
      layout "manage"

      def index
        authorize! :show, Message
        @participants = current_user.participants
        render(
          locals: {
            received_messages: received_messages,
            sent_messages: sent_messages
          }
        )
      end

      def new
        authorize! :new, Message
        render(
          locals: {
            message: message_for_reply,
            new_message: current_user.build_sent_message,
            participants: current_user.participants
          }
        )
      end

      def create
        authorize! :create, Message
        @message = current_user.build_sent_message(message_params)
        if @message.save
          redirect_to coach_messages_url, notice: "Message saved"
        else
          errors = @message.errors.full_messages.join(", ")
          flash.now[:alert] = "Unable to save message: #{ errors }"
          render :new
        end
      end

      def reply
        authorize! :create, Message
      end

      private

      def message_for_reply
        received_messages.find(params[:message_id]) if params[:message_id]
      end

      def received_messages
        messages = current_user
                   .received_messages
                   .joins(:message)
                   .order("messages.sent_at DESC")
        return messages unless params[:search]

        messages.sent_from(params[:search])
      end

      def sent_messages
        messages = current_user.sent_messages.order("messages.sent_at DESC")
        return messages unless params[:search]

        messages.where(recipient_id: params[:search])
      end

      def message_params
        params
          .require(:message)
          .permit(:recipient_id, :recipient_type, :subject, :body)
      end
    end
  end
end
