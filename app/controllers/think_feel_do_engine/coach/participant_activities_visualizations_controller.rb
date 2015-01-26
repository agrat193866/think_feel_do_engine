module ThinkFeelDoEngine
  module Coach
    # Present Participant Activities Visualization to the Coach.
    class ParticipantActivitiesVisualizationsController < ApplicationController
      before_action :authenticate_user!

      layout "manage"

      RenderOptions = Struct.new(
        :view_context, :app_context, :position, :participant
      )

      def show
        @participant = Participant.find(params[:participant_id])
        provider = ContentProviders::YourActivitiesProvider.new
        options = RenderOptions.new(
          self,
          @participant.navigation_status,
          @participant.navigation_status.content_position,
          @participant
        )
        provider.render_current(options)
      end
    end
  end
end
