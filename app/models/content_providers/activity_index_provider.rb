module ContentProviders
  # Provides a view of Activities that occured during a Participant"s most
  # recent AwakePeriod.
  class ActivityIndexProvider < BitCore::ContentProvider
    def data_class_name
      "Activity"
    end

    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/index",
        locals: {
          activities: options
            .participant
            .recent_activities
            .order("start_time ASC")
        }
      )
    end

    def show_nav_link?
      true
    end
  end
end
