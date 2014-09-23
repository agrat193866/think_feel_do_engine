module ContentProviders
  # Provides multiple forms for a Participant to enter Thoughts.
  class NewThoughtsFormProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/new_bulk",
        locals: {
          thoughts: (1..2).map { options.participant.thoughts.build },
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "Thought"
    end

    def data_attributes
      [:content, :effect]
    end

    def show_nav_link?
      false
    end
  end
end
