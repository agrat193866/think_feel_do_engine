module ThinkFeelDoEngine
  module Coach
    # Displays navigational information in the form of breadcrumbs
    module PatientDashboardHelper
      VISUALIZATION_CONTROLLERS = [
        "participant_activities_visualizations",
        "participant_thoughts_visualizations"
      ]

      def breadcrumbs
        return unless VISUALIZATION_CONTROLLERS.include?(controller_name)

        dashboard_path = coach_group_patient_dashboard_path(
          @participant.active_group,
          @participant
        )

        content_for(
          :breadcrumbs,
          content_tag(
            :ol,
            content_tag(
              :li,
              link_to("Patient Dashboard", dashboard_path)
            ),
            class: "breadcrumb"
          )
        )
      end

      def activities_planned_today(participant)
        participant.activities.planned.for_day(Date.today).count +
          participant.activities.reviewed_and_complete.for_day(Date.today).count +
          participant.activities.reviewed_and_incomplete.for_day(Date.today).count
      end

      def activities_planned_7_day(participant)
        participant.activities.planned.last_seven_days.count +
          participant.activities.reviewed_and_complete.last_seven_days.count +
          participant.activities.reviewed_and_incomplete.last_seven_days.count
      end

      def activities_planned_total(participant)
        participant.activities.planned.count +
          participant.activities.reviewed_and_complete.count +
          participant.activities.reviewed_and_incomplete.count
      end
    end
  end
end
