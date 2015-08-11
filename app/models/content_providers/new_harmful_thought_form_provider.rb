module ContentProviders
  # Provides a form for a Participant to enter a Thought.
  class NewHarmfulThoughtFormProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/new_harmful",
        locals: {
          thought: options.participant.thoughts
                   .build(effect: Thought::EFFECTS[:harmful]),
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "Thought"
    end

    def data_attributes
      [:content, :effect, :pattern_id]
    end

    def show_nav_link?
      false
    end
  end
end
