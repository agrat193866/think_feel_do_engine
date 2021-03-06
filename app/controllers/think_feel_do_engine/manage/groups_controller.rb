module ThinkFeelDoEngine
  module Manage
    # Users can view groups to CRUD and assign slideshows
    class GroupsController < ApplicationController
      before_action :authenticate_user!, :set_arm
      load_and_authorize_resource except: :edit_tasks

      def index
      end

      def edit_tasks
        @group = @arm.groups
                 .includes(tasks: { bit_core_content_module: :tool })
                 .find(params[:id])
        authorize! :update, @group
        @task = current_user.tasks.build
        @content_modules = BitCore::ContentModule
                           .where(bit_core_tool_id: @arm.bit_core_tool_ids)
                           .includes(:tool)
      end

      private

      def set_arm
        @arm = Arm.find(params[:arm_id])
      end
    end
  end
end
