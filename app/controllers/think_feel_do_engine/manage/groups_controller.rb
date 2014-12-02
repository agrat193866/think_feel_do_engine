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
        @task = current_user.tasks.build
        # @content_modules = BitCore::ContentModule.where(bit_core_tool_id: @arm.bit_core_tools.map(&:id))
        @content_modules ||= BitCore::ContentModule.all
      end
    end
  end
end
