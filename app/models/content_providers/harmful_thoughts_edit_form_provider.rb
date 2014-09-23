module ContentProviders
  # Provides a form for a Participant to identify harmful Thoughts by their
  # ThoughtPatterns.
  class HarmfulThoughtsEditFormProvider < BitCore::ContentProvider
    def render_current(options)
      thoughts = options.participant.thoughts.harmful.no_pattern

      options.view_context.render(
        template: "think_feel_do_engine/thoughts/edit_bulk",
        locals: {
          thoughts: thoughts,
          update_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "Thought"
    end

    def data_attributes
      [
        :id, :pattern_id
      ]
    end

    def show_nav_link?
      false
    end
  end
end
