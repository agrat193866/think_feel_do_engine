module ContentProviders
  # Provides a form for a Participant to update previously planned Activities.
  class PastActivityReviewForm < BitCore::ContentProvider
    def render_current(options)
      activities = options.participant.activities
        .in_the_past
        .incomplete

      options.view_context.render(
        template: "think_feel_do_engine/activities/past_activity_review",
        locals: {
          activities: activities,
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
        :is_complete, :noncompliance_reason
      ]
    end

    def show_nav_link?
      false
    end
  end
end
