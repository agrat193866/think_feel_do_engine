module ContentProviders
  # Provides a list of a Participant"s helpful Thoughts.
  class HelpfulThoughtsIndexProvider < BitCore::ContentProvider
    def data_class_name
      "Thought"
    end

    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thoughts/index",
        locals: {
          title: "Helpful Thoughts",
          introduction: introduction,
          thoughts: options.participant.thoughts.helpful
        }
      )
    end

    def show_nav_link?
      true
    end

    private

    def introduction
      "<p>Last time you were here...<br>" \
        "You noted that you've been thinking some things that are helpful." \
        "<p>Being aware of these thoughts can be helpful.".html_safe
    end
  end
end
