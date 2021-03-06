module ThinkFeelDoEngine
  # Used ONLY in development to speed up manual logins.
  class QuickSignInsController < ApplicationController
    skip_authorization_check

    def new
      if params[:user_id]
        resource = User.where(id: params[:user_id]).first
      elsif params[:participant_id]
        ParticipantLoginEvent.create(participant_id: params[:participant_id])
        resource = Participant.where(id: params[:participant_id]).first
      end
      if resource
        sign_in_and_redirect resource
      end
    end
  end
end
