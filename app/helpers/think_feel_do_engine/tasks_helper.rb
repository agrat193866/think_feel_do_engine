module ThinkFeelDoEngine
  # Used to display asterisks if tasks and tools have been assigned to a group
  # and to hide unassigned links
  module TasksHelper
    def task_status(membership, content_module)
      membership.available_task_statuses
        .for_content_module(content_module)
        .order(start_day: :asc)
        .last
    end

    def task_status_viz(task_status)
      task_status.title
    end

    def task_status_link(available_module:, icon:, membership:)
      available_module = TaskStatusLink.new(
        available_module: available_module,
        icon: icon,
        membership: membership)
      link_to available_module.name,
              think_feel_do_engine.navigator_location_path(
                module_id: available_module.id
              ), class: available_module.css_class,
                 data: available_module.data_attributes,
                 id: available_module.css_id
    end

    def unread_task?(task_status)
      !task_status.completed_at?
    end

    def todays_lesson(task_status, response)
      membership = current_participant.membership
      response.html_safe if task_status.release_day == membership.day_in_study
    end

    def current_provider_skippable?(navigator)
      provider = navigator.current_content_provider
      mod = navigator.current_module
      membership = current_participant.active_membership

      # If the TaskStatus was *just* marked complete, this is the first time
      # viewing the ContentProvider, so we should consider it incomplete.
      ContentProviderDecorator.fetch(provider)
        .is_skippable_after_first_viewing &&
        task_status(membership, mod).completed_at < Time.current - 5.minutes
    end

    def create_task_path(task_status)
      think_feel_do_engine.navigator_location_path(
        module_id: task_status
                   .bit_core_content_module_id,
        provider_id: task_status
                     .bit_core_content_module
                     .content_providers
                     .find_by_position(1)
                     .id,
        content_position: 1
      )
    end
  end

  # Helper class to build task status link
  class TaskStatusLink
    attr_reader :available_module, :icon, :membership

    def initialize(available_module:, icon:, membership:)
      @available_module = available_module
      @icon = icon
      @membership = membership
    end

    def css_class
      "task-status list-group-item list-group-item-#{completion_status}"
    end

    def css_id
      "task-status-#{ available_module.task_status_id }"
    end

    def data_attributes
      {
        task_status_id: available_module.task_status_id
      }
    end

    def id
      available_module.id
    end

    def name
      icon.html_safe + " " +  available_module.title
    end

    private

    def completed?
      membership.available_task_statuses
        .for_content_module(available_module)
        .order(start_day: :asc)
        .last
        .completed_at
    end

    def completion_status
      completed? ? "read" : "unread"
    end
  end
end
