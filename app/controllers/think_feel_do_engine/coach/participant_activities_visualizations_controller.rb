module ThinkFeelDoEngine
  module Coach
    # Present Participant Activities Visualization to the Coach.
    class ParticipantActivitiesVisualizationsController < ApplicationController
      before_action :authenticate_user!

      layout "manage"

      def show
        participant = Participant.find(params[:participant_id])
        scheduled_activities = participant
                               .activities
                               .where(is_scheduled: true)
                               .in_the_past
                               .order(start_time: :desc)
        activities = participant
                     .activities
                     .in_the_past
                     .order(start_time: :desc)

        render "think_feel_do_engine/activities/visualization",
               locals: {
                 activities: activities,
                 scheduled_activities: scheduled_activities
               }
      end
    end
  end
end
