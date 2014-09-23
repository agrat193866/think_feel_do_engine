module ThinkFeelDoEngine
  module Manage
    # User manages task creation, destruction, and assignment for groups
    class TasksController < ApplicationController
      before_action :authenticate_user!
      before_action :build_task, only: [:create]
      load_and_authorize_resource
      layout "manage"

      def index
        @group = Group.find(params[:group_id])
        @learning_tasks = @group.learning_tasks
      end

      def create
        if @task.save
          redirect_to manage_tasks_group_path(@task.group),
                      notice: "Task assigned."
        else
          errors = @task.errors.full_messages.join(", ")
          flash[:alert] = "Unable to assign task: #{ errors }"
          redirect_to manage_tasks_group_path(@task.group)
        end
      end

      def destroy
        deleted_group = @task.group
        if @task.destroy
          flash.now[:success] = "Task unassigned from group."
          redirect_to manage_tasks_group_path(deleted_group)
        else
          errors = @task.errors.full_messages.join(", ")
          flash[:error] = "Unable to delete task from group: #{ errors }"
          redirect_to manage_tasks_group_path(@task.group)
        end
      end

      private

      def build_task
        @task ||= current_user.tasks.build(
          params.require(:task).permit(
            :bit_core_content_module_id,
            :group_id,
            :is_recurring,
            :release_day,
            :termination_day,
            :has_didactic_content
          )
        )
      end
    end
  end
end
