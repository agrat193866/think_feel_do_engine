module ThinkFeelDoEngine
  # Manage messages from the site to Participants.
  class SiteMessagesController < ApplicationController
    before_action :authenticate_user!

    layout "manage"

    def index
      participant_ids = current_user.participant_ids
      @site_messages = SiteMessage.where(participant_id: participant_ids)
    end

    def show
      @site_message = SiteMessage.find(params[:id])
      authorize! :show, @site_message
    end

    def new
      @participants = current_user.participants
      @site_message = SiteMessage.new
    end

    def create
      @site_message = SiteMessage.new(site_message_params)
      authorize! :create, @site_message

      if @site_message.save
        SiteMessageMailer.general(@site_message).deliver

        redirect_to @site_message,
                    notice: "Site message was successfully created."
      else
        render :new
      end
    end

    private

    def site_message_params
      params.require(:site_message).permit(:participant_id, :subject, :body)
    end
  end
end
