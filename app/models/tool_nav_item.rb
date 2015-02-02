# A nav item related to a Bit Core Tool.
class ToolNavItem
  def self.for_participant(participant)
    participant.active_group.arm.non_home_tools.order(:position)
      .map { |t| new(participant, t) }
  end

  def initialize(participant, tool)
    @participant = participant
    @tool = tool
  end

  def title
    @tool.title
  end

  def alert
    case @tool.type
    when nil
      any_incomplete_tasks_today? ? "New!" : nil
    else
      count = @participant.count_all_incomplete(@tool)

      count > 0 ? count : nil
    end
  end

  def is_active?(current_module)
    all_module_ids.include?(current_module.id)
  end

  def has_subnav?
    @tool.type.nil?
  end

  def module_nav_items
    ModuleNavItem.for_content_modules(@participant, available_content_modules)
  end

  def any_incomplete_tasks_today?
    content_module_ids = available_content_modules.where(is_viz: false)
                         .map(&:id)

    @participant.active_membership
      .incomplete_tasks_today
      .for_content_module_ids(content_module_ids)
      .exists?
  end

  private

  def available_content_modules
    @available_content_modules ||= (
      tasks = Task.where(group_id: @participant.active_group.id,
                         bit_core_content_module_id: all_module_ids)
                  .joins(:task_statuses)
                  .merge(@participant.active_membership.available_task_statuses)

      BitCore::ContentModule.where(id: tasks.map(&:bit_core_content_module_id))
    )
  end

  def all_module_ids
    @all_module_ids ||= @tool.content_modules.map(&:id)
  end
end
