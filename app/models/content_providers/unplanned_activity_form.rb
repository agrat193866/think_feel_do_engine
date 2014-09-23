module ContentProviders
  # Provides forms for a Provider to plan Activities.
  class UnplannedActivityForm < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/unplanned_activity_form",
        locals: {
          activities: options.participant.activities.random.unplanned.first(4),
          update_path: options.view_context.participant_data_path,
          already_sched_activities: options
                                  .view_context
                                  .current_participant
                                  .activities
                                  .in_the_future
                                  .order(start_time: :asc)
        }
      )
    end

    def data_attributes
      [
        :id, :start_time, :end_time, :activity_type_title,
        :predicted_pleasure_intensity, :predicted_accomplishment_intensity
      ]
    end

    def data_class_name
      "Activity"
    end

    def show_nav_link?
      false
    end
  end
end
