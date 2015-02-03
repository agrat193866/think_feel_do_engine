module ContentProviders
  # Visualizations of participant activities.
  class YourActivitiesProvider < BitCore::ContentProvider
    def render_current(options, _ = nil)
      options.view_context.render(
        template: "think_feel_do_engine/activities/visualization",
        locals: {
          activities: activities(options),
          local_time: local_time(options),
          formatted_date: formatted_date(options),
          moods: moods(options),
          negative_emotions: negative_emotions(options),
          positive_emotions: positive_emotions(options),
          completed_week_activities: completed_week_activities(options),
          dates_with_activities:  collect_dates_with_activities(options)
        }
      )
    end

    def activities(options)
      options
        .participant
        .activities
        .order(start_time: :asc)
        .for_day(local_time(options))
    end

    def past_activities(options)
      options
        .participant
        .activities
    end

    def moods(options)
      options
        .participant
        .moods
        .order(created_at: :asc)
        .for_day(local_time(options))
    end

    def negative_emotions(options)
      options
        .participant
        .emotional_ratings
        .negative
        .order(created_at: :asc)
        .for_day(local_time(options))
    end

    def positive_emotions(options)
      options
        .participant
        .emotional_ratings
        .positive
        .order(created_at: :asc)
        .for_day(local_time(options))
    end

    def completed_week_activities(options)
      options
        .participant
        .activities
        .last_seven_days
        .completed
        .order(start_time: :asc)
    end

    def formatted_date(options)
      local_time(options)
        .strftime("%b %d, %Y")
    end

    # dates with scheduled activities formatted for jquery datepicker
    def collect_dates_with_activities(options)
      past_activities(options).where("start_time <= ?", Time.now)
        .uniq
        .map { |activity| activity.start_time.to_date.strftime("%Y-%m-%d") }
    end

    def local_time(options)
      if options.view_context.params[:date]
        options.view_context.params[:date].to_time
      else
        Time.zone.now
      end
    end

    def show_nav_link?
      false
    end
  end
end
