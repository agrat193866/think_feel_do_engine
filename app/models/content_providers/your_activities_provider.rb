module ContentProviders
  # Visualizations of participant activities.
  class YourActivitiesProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/visualization_2",
        locals: {
          activities: activities(options),
          formatted_date: formatted_date(options),
          datetime: datetime(options)
        }
      )
    end

    def activities(options)
      options
        .participant
        .activities
        .order(start_time: :desc)
        .for_day(datetime(options))
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

# module ContentProviders
#   # Visualizations of participant activities.
#   class YourActivitiesProvider < BitCore::ContentProvider
#     def render_current(options)
#       scheduled_activities =
#         options
#         .participant
#         .activities
#         .where(is_scheduled: true)
#         .in_the_past
#         .order(start_time: :desc)
#       activities =
#         options
#         .participant
#         .activities
#         .in_the_past
#         .order(start_time: :desc)
#       options.view_context.render(
#         template: "think_feel_do_engine/activities/visualization",
#         locals: {
#           activities: activities,
#           scheduled_activities: scheduled_activities
#         }
#       )
#     end

#     def show_nav_link?
#       false
#     end
#   end
# end
