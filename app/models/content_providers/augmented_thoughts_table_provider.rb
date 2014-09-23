module ContentProviders
  # Provides a form for a Participant to enter a Thought.
  class AugmentedThoughtsTableProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/thoughts_table",
        locals: {
          hide_new_path: true,
          thoughts: options.participant.thoughts.harmful
        }
      )
    end

    def show_nav_link?
      true
    end
  end
end
