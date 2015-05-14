module ContentProviders
  # Provides a form for a Participant to schedule new Activities that have
  # been fun in the past.
  class FunActivityChecklist < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/activities/fun_activity_checklist",
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
        :start_time
      ]
    end

    def data_class_name
      "PlannedActivity"
    end

    def show_nav_link?
      false
    end

    private

    def activities(participant)
      participant.activities
        .pleasurable
        .random
        .in_the_past
        .first(5)
    end
  end
end
