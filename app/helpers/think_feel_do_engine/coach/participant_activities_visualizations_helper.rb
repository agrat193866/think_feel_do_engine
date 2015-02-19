module ThinkFeelDoEngine
  module Coach
    # Displays navigational information in the form of breadcrumbs
    module PatientDashboardHelper
      VISUALIZATION_CONTROLLERS = [
        "participant_activities_visualizations",
        "participant_thoughts_visualizations"
      ]
      def breadcrumbs
        if VISUALIZATION_CONTROLLERS.include? controller_name
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
      end
    end
  end
end
