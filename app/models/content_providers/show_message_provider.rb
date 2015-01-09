module ContentProviders
  # Provides a view of a sent or received Message.
  class ShowMessageProvider < BitCore::ContentProvider
    def data_class_name
      "Message"
    end

    def show_nav_link?
      false
    end

    def render_current(options)
      message = load_message(options)
      message.try(:mark_read)

      options.view_context.render(
        template: "think_feel_do_engine/messages/show",
        locals: {
          coach: options.participant.coach,
          compose_path: compose_path(options),
          message: message,
          reply_path: compose_path(options) + new_mail_params(options)
        }
      )
    end

    private

    def compose_path(options)
      provider_id =
        content_module
        .content_providers
        .find_by_type("ContentProviders::NewMessageFormProvider").id

      options.view_context.navigator_location_path(
        context: "messages",
        module_id: content_module.id,
        provider_id: provider_id,
        content_position: 1
      )
    end

    def load_message(options)
      participant = options.participant
      view_context = options.view_context

      received_message =
        participant.received_messages
        .where(message_id: view_context.params[:message_id]).first
      sent_message =
        participant.messages
        .where(id: view_context.params[:message_id]).first

      received_message || sent_message
    end

    def new_mail_params(options)
      message = load_message(options)

      "&compose_path=#{compose_path(options)}"\
      "&message_id=#{message.id}"\
      "&subject=Reply: #{message.subject}"\
      "&recipient_id=#{message.sender.id}"\
      "&recipient_type=#{message.sender.class}"\
      "&recipient=#{message.from(responder(options))}"
    end

    def responder(options)
      vc = options.view_context
      vc.current_participant || vc.current_user
    end
  end
end
