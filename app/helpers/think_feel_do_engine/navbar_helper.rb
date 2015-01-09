module ThinkFeelDoEngine
  # Used to display nested links in the navbar
  module NavbarHelper
    def content_module_tasks(tool)
      @content_module_tasks ||= {}

      @content_module_tasks[tool.id] ||= (
        icon = "pencil"
        content_module_ids = tool
                             .content_modules
                             .order(position: :asc)
                             .map(&:id)

        icon_prev = "-"
        task_statuses = task_statuses_by_id(content_module_ids)

        content_module_ids.map do |content_module_id|
          task_status =  task_statuses[content_module_id]
          next if !task_status || viz_providers.find do |p|
            p.bit_core_content_module_id ==
              task_status.try(:bit_core_content_module).try(:id)
          end
          icon = task_status.task.has_didactic_content ? "book" : "pencil"
          icon_prev = icon if icon_prev == "-"
          divider = icon != icon_prev ? "DIVIDE" : nil
          icon_prev = icon

          [divider, task_status_link(task_status, "", icon)].compact
        end.flatten.unshift("DIVIDE")
      )
    end

    private

    def viz_providers
      @viz_providers ||= BitCore::ContentProvider
                         .select(:id, :bit_core_content_module_id, :position,
                                 :type)
                         .where(position: 1)
                         .all.select { |p| p.try(:viz?) }
    end

    def task_statuses_by_id(content_module_ids)
      @available_task_statuses ||=
        current_participant
        .membership
        .available_task_statuses
        .includes(task: :bit_core_content_module)

      task_statuses = {}
      tasks = Task
              .where(bit_core_content_module_id: content_module_ids)
              .group_by(&:id)
      @available_task_statuses.each do |s|
        next unless tasks[s.task_id]
        task_statuses[tasks[s.task_id][0].bit_core_content_module_id] = s
      end

      task_statuses
    end
  end
end
