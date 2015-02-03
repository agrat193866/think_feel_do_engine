module ContentProviders
  # Provides a form for a Participant to enter a Thought.
  class ThoughtsDistortionVizProvider < BitCore::ContentProvider
    def data_class_name
      "Thought"
    end

    def render_current(options, link_to_fullpage = nil)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/distortion_viz",
        locals: {
          thoughts: options.view_context.current_participant.thoughts.harmful,
          link_to_view: link_to_fullpage
        }
      )
    end

    def show_nav_link?
      false
    end
  end
end
