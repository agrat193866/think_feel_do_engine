module ContentProviders
  # Provides a display of recent pleasurable Activities.
  class PleasurableActivityIndexProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/pleasurable_index",
        locals: {
          activities: options
            .participant
            .recent_pleasurable_activities
            .order(start_time: :asc)
        }
      )
    end

    def show_nav_link?
      true
    end
  end
end
