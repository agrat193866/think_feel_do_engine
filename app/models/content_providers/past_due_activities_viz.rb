module ContentProviders
  # Provides a view of Activities that occured during a Participant"s most
  # recent AwakePeriod.
  class PastDueActivitiesViz < BitCore::ContentProvider
    def render_current(view_context, _link_to_fullpage)
      past_due = past_due_activities(view_context)
      upcoming = upcoming_activities(view_context)
      view_context.render(
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

    def past_due_activities(view_context)
      view_context
        .current_participant
        .activities
        .in_the_past
        .incomplete
        .order(start_time: :desc)
    end

    def upcoming_activities(view_context)
      view_context
        .current_participant
        .activities
        .in_the_future
        .incomplete
        .order(start_time: :asc)
    end
  end
end
