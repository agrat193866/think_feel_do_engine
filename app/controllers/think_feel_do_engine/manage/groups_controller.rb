module ThinkFeelDoEngine
  module Manage
    # Users can view groups to CRUD and assign slideshows
    class GroupsController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource
      layout "manage"

      def index
      end

      def edit_tasks
        @content_modules ||= BitCore::ContentModule.all
      end
    end
  end
end
