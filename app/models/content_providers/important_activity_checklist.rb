module ContentProviders
  # Provides a checklist of a random set of Activities for a Participant to
  # plan.
  class ImportantActivityChecklist < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/" \
                  "important_activity_checklist",
        locals: {
          past_activities: activities(options.participant),
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_attributes
      [
        :activity_type_title,
        :activity_type_new_title,
        :predicted_pleasure_intensity,
        :predicted_accomplishment_intensity,
        :start_time,
        :is_scheduled
      ]
    end

    def data_class_name
      "Activity"
    end

    def show_nav_link?
      false
    end

    private

    def activities(participant)
      participant.activities
        .accomplished
        .random
        .in_the_past
        .first(5)
    end
  end
end
