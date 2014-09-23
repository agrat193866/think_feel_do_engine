module ContentProviders
  # Provides a form for a Participant to enter a Thought.
  class ThoughtsDistortionVizProvider < BitCore::ContentProvider
    def data_class_name
      "Thought"
    end

    def viz?
      true
    end

    def render_current(*args)
      if args.size == 2
        render_current_home(args[0], args[1])
      elsif args.size == 1
        render_current_solo(args[0])
      end
    end

    def render_current_solo(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/distortion_viz",
        locals: {
          thoughts: options.view_context.current_participant.thoughts.harmful
        }
      )
    end

    # The vizualization renderer on the homepage
    def render_current_home(view_context, link_to_fullpage)
      view_context.render(
        template: "think_feel_do_engine/thoughts/distortion_viz",
        locals: {
          thoughts: view_context.current_participant.thoughts.harmful,
          link_to_view: link_to_fullpage
        }
      )
    end

    def show_nav_link?
      false
    end
  end
end
