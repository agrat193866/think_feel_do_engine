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
    current_module.bit_core_tool_id == @tool.id
  end

  def has_subnav?
    @tool.type.nil?
  end

  def module_nav_items
    available_content_modules
      .position_greater_than(1)
      .is_not_viz
      .available_by(Date.today)
      .order_by_position
      .latest_duplicate
  end

  def any_incomplete_tasks_today?
    available_content_modules
      .is_not_viz
      .is_not_completed
      .available_on(Date.today)
      .exists?
  end

  private

  def available_content_modules
    AvailableContentModule
      .for_tool(@tool)
      .for_participant(@participant)
  end
end
