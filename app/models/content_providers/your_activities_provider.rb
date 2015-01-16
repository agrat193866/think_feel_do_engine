module ContentProviders
  # Visualizations of participant activities.
  class YourActivitiesProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/visualization",
        locals: {
          activities: activities(options),
          datetime: datetime(options),
          formatted_date: formatted_date(options),
          moods: moods(options),
          negative_emotions: negative_emotions(options),
          positive_emotions: positive_emotions(options),
          completed_week_activities: completed_week_activities(options)
        }
      )
    end

    def activities(options)
      options
        .participant
        .activities
        .order(start_time: :asc)
        .for_day(datetime(options))
    end

    def moods(options)
      options
        .participant
        .moods
        .order(created_at: :asc)
        .for_day(datetime(options))
    end

    def negative_emotions(options)
      options
        .participant
        .emotional_ratings
        .negative
        .order(created_at: :asc)
        .for_day(datetime(options))
    end

    def positive_emotions(options)
      options
        .participant
        .emotional_ratings
        .positive
        .order(created_at: :asc)
        .for_day(datetime(options))
    end

    def completed_week_activities(options)
      options
        .participant
        .activities
        .last_seven_days
        .where(is_scheduled: true)
        .order(start_time: :asc)
    end

    def formatted_date(options)
      datetime(options)
        .strftime("%b %d, %Y")
    end

    def datetime(options)
      if options.view_context.params[:date]
        options.view_context.params[:date].to_datetime
      else
        DateTime.current
      end
    end

    def show_nav_link?
      false
    end
  end
end