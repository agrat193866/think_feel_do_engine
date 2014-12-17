module ThinkFeelDoEngine
  # Used to display nested links in the navbar
  module NavbarHelper
    def content_module_tasks(tool, link_class, icon = "pencil")
      content_modules = tool
                        .content_modules
                        .order(position: :asc)

      icon_prev = "-"
      task_statuses = task_statuses_by_id(content_modules)
      content_modules.map do |content_module|
        task_status =  task_statuses[content_module.id]
        next if !task_status || task_status.provider_viz?
        icon = task_status.task.has_didactic_content ? "book" : "pencil"
        icon_prev = icon if icon_prev == "-"
        divider = icon != icon_prev ? "DIVIDE" : nil
        icon_prev = icon

        [divider, task_status_link(task_status, link_class, icon)]
      end.flatten.compact
    end

    private

    def task_statuses_by_id(content_modules)
      task_statuses = {}
      tasks = Task
              .where(bit_core_content_module_id: content_modules.map(&:id))
              .group_by(&:id)
      current_participant
        .membership
        .available_task_statuses
        .includes(task: :bit_core_content_module)
        .order(start_day: :asc).each do |s|
        next unless tasks[s.task_id]
        task_statuses[tasks[s.task_id][0].bit_core_content_module_id] = s
      end

      task_statuses
    end
  end
end
