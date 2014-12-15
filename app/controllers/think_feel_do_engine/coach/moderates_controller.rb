module ThinkFeelDoEngine
  module Coach
    # Allows Coaches/Clinicians to moderate.
    # That is, log in as a participant
    class ModeratesController < ApplicationController
      before_action :authenticate_user!, :set_group
      # skip_authorization_check

      # POST /coach/groups/:group_id/moderates    
      def create
        authorize! :moderate, @group
        sign_in_and_redirect @group.moderator
      end

      protected

      def after_sign_up_path_for(resource)
        root_path
      end

      private

      def set_group
        @group = Group.find(params[:group_id])
      end
    end
  end
end
