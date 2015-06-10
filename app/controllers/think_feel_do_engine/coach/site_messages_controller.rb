module ThinkFeelDoEngine
  module Coach
    # Manage messages from the site to Participants.
    class SiteMessagesController < ApplicationController
      before_action :authenticate_user!, :set_group
      load_and_authorize_resource except: [:index]

      def index
        authorize! :index, SiteMessage
        participant_ids = current_user.participants_for_group(@group).ids
        @site_messages =
          SiteMessage
          .where(participant_id: participant_ids)
      end

      def show
      end

      def new
        @participants = current_user.participants_for_group(@group)
      end

      def create
        if @site_message.save
          SiteMessageMailer.general(@site_message).deliver

          redirect_to coach_group_site_message_path(@group, @site_message),
                      notice: "Site message was successfully created."
        else
          render :new
        end
      end

      private

      def site_message_params
        params
          .require(:site_message)
          .permit(
            :participant_id, :subject, :body
          )
      end

      def set_group
        @group = Group.find(params[:group_id])
      end
    end
  end
end
