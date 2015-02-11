module ThinkFeelDoEngine
  module Coach
    module ParticipantActivitiesVisualizationsHelper
      def breadcrumbs
        if controller_name == "participant_activities_visualizations"
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
