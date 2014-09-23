module ContentProviders
  # Provides a form for a Participant to plan a new Activity.
  class InputNewActivityForm < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/input_new_activity_form",
        locals: {
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_attributes
      [
        "1" => [:activity_type_title, :predicted_accomplishment_intensity],
        "0" => [:activity_type_title, :predicted_pleasure_intensity]
      ]
    end

    def data_class_name
      "UnplannedActivities"
    end

    def show_nav_link?
      false
    end
  end
end
