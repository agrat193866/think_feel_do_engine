module ContentProviders
  # Provides a set of forms to update a Participant's unhelpful Thoughts.
  class UnhelpfulThoughtsReflectionProvider < BitCore::ContentProvider
    def show_nav_link?
      false
    end

    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/unhelpful_thoughts_form",
        locals: {
          thoughts: options.participant.thoughts.unreflected.last(3),
          update_path: options.view_context.participant_data_path
        }
      )
    end

    def data_attributes
      [:challenging_thought, :act_as_if, :id]
    end

    def data_class_name
      "Thought"
    end
  end
end
