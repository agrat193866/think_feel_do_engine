module ThinkFeelDoEngine
  module Manage
    # User manages task creation, destruction, and assignment for groups
    class TasksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_group, only: [:index, :create]
      before_action :set_task, only: :destroy
      layout "manage"

      def index
        authorize! :update, @group
        @learning_tasks = @group.learning_tasks
      end

      def create
        @task = current_user
          .tasks
          .build(task_params)
        authorize! :create, @task
        if @task.save
          redirect_to manage_tasks_group_path(@group),
                      notice: "Task assigned."
        else
          errors = @task.errors.full_messages.join(", ")
          flash[:alert] = "Unable to assign task: #{ errors }"
          redirect_to manage_tasks_group_path(@group)
        end
      end

      def destroy
        authorize! :destroy, @task
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
        current_user
          .tasks
          .build(task_params)
      end

      def set_group
        @group = Group.find(task_params[:group_id])
      end

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(
          :bit_core_content_module_id,
          :group_id,
          :is_recurring,
          :release_day,
          :termination_day,
          :has_didactic_content
        )
      end
    end
  end
end
