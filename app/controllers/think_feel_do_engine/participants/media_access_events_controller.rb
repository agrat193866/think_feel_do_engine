module ThinkFeelDoEngine
  module Participants
    # Manage Participant Activities.
    class MediaAccessEventsController < ApplicationController
      before_action :authenticate_participant!

      def create
        @media_access_event = current_participant
                              .media_access_events
                              .build(media_access_event_params)
        if @media_access_event.save
          render json: { media_access_event_id: @media_access_event.id, status: 201 }
        else
          head :unprocessable_entity
        end
      end

      def update
        @media_access_event = MediaAccessEvent.find(params[:id])
        if @media_access_event.update(media_access_event_params)
          head :ok
        else
          head :unprocessable_entity
        end
      end

      private

      def media_access_event_params
        params.require(:media_access_event)
          .permit([
            :media_type, :media_link, :end_time, :id
          ])
      end
    end
  end
end
