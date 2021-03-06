module ContentProviders
  # Provides a view of Activities that occured during a Participant"s most
  # recent AwakePeriod.
  class PastDueActivitiesViz < BitCore::ContentProvider
    def render_current(options, _ = nil)
      past_due = past_due_activities(options)
      upcoming = upcoming_activities(options)
      options.view_context.render(
        partial: "think_feel_do_engine/activities/" \
                 "past_due_activities_index_viz",
        locals: {
          past_due_count: past_due.count,
          upcoming_count: upcoming.count,
          past_due_activities: past_due.limit(4),
          upcoming_activities: upcoming.limit(4)
        }
      )
    end

    private

    def past_due_activities(options)
      options
        .participant
        .activities
        .in_the_past
        .planned
        .order(start_time: :desc)
    end

    def upcoming_activities(options)
      options
        .participant
        .activities
        .in_the_future
        .planned
        .order(start_time: :asc)
    end
  end
end
