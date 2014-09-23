module ContentProviders
  # Provides a list of all ThoughtPatterns.
  class ThoughtPatternsIndexProvider < BitCore::ContentProvider
    def data_class_name
      "ThoughtPattern"
    end

    def show_nav_link?
      false
    end

    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thought_patterns/index",
        locals: {
          thought_patterns: ThoughtPattern.all
        }
      )
    end
  end
end
