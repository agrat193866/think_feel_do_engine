module ContentProviders
  # Provides a form for a Participant to compose a new Message.
  class NewMessageFormProvider < BitCore::ContentProvider
    def render_current(options)
      view = options.view_context
      authorize! options.participant, view
      view.render(
        template: "think_feel_do_engine/messages/new",
        locals: {
          compose_path: view.params[:compose_path],
          create_path: view.participant_data_path,
          message: message_for_reply(options),
          new_message: message(options.participant),
          recipient: view.params[:recipient],
          recipient_id: view.params[:recipient_id],
          recipient_type: view.params[:recipient_type],
          subject: view.params[:subject]
        }
      )
    end

    def data_class_name
      "Message"
    end

    def data_attributes
      [:body, :recipient_id, :recipient_type, :subject]
    end

    def show_nav_link?
      false
    end

    private

    def message_for_reply(options)
      if options.view_context.params[:message_id]
        options
          .participant
          .received_messages
          .find(options.view_context.params[:message_id])
      end
    end

    def message(participant)
      coach = participant.coach

      participant.sent_messages.build(
        recipient_id: coach.id,
        recipient_type: coach.class.to_s
      )
    end

    def authorize!(participant, view)
      unless participant.active_membership.present?
        view.controller.redirect_to view.root_url
      end
    end
  end
end
