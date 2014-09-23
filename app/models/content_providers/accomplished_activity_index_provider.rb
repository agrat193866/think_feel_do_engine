module ContentProviders
  # Provides a view of completed Activities during the Participant"s most
  # recent AwakePeriod.
  class AccomplishedActivityIndexProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/accomplished_index",
        locals: {
          activities: options
            .participant
            .recent_accomplished_activities
            .order(start_time: :asc)
        }
      )
    end

    def show_nav_link?
      true
    end
  end
end
