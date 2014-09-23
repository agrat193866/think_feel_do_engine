module ContentProviders
  # Provides a graphic helps patients understand how they can
  # evaluate their thoughts for accuracy - challenge their thoughts
  class EvaluateThoughtsProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/thought_patterns/evaluating"
      )
    end

    def show_nav_link?
      true
    end
  end
end
