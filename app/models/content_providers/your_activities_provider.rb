module ContentProviders
  # Visualizations of participant activities.
  class YourActivitiesProvider < BitCore::ContentProvider
    def render_current(options)
      scheduled_activities =
        options
        .participant
        .activities
        .where(is_scheduled: true)
        .in_the_past
        .order(start_time: :desc)
      activities =
        options
        .participant
        .activities
        .in_the_past
        .order(start_time: :desc)
      options.view_context.render(
        template: "think_feel_do_engine/activities/visualization",
        locals: {
          activities: activities,
          scheduled_activities: scheduled_activities
        }
      )
    end

    def show_nav_link?
      false
    end
  end
end
