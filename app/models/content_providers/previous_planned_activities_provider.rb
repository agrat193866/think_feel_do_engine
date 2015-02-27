module ContentProviders
  # Provides a form for a Participant to update previously planned Activities.
  class PreviousPlannedActivitiesProvider < BitCore::ContentProvider
    def render_current(options)
      activities =
        options
        .participant
        .activities
        .incomplete

      options.view_context.render(
        template: "think_feel_do_engine/activities/previously_planned_fullpage",
        locals: {
          activities_list: activities.order("start_time ASC"),
          update_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "Activity"
    end

    def data_attributes
      [
        :id, :actual_pleasure_intensity, :actual_accomplishment_intensity,
        :noncompliance_reason
      ]
    end

    def show_nav_link?
      false
    end
  end
end
