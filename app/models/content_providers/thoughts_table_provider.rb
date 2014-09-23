module ContentProviders
  # Provides a form for a Participant to enter a Thought.
  class ThoughtsTableProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/thoughts_table",
        locals: {
          thoughts: options.participant.thoughts.harmful
        }
      )
    end

    def show_nav_link?
      false
    end
  end
end
