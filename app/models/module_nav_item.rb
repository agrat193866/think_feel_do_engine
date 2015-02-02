# A Nav menu item listed under a Tool Nav Item.
class ModuleNavItem
  def self.for_content_modules(participant, content_modules)
    content_modules.order(:position).where("position > 1")
      .where(is_viz: false)
      .map { |m| new(participant, m) }
  end

  def initialize(participant, content_module)
    @participant = participant
    @content_module = content_module
  end

  def title
    @content_module.title
  end

  def module_id
    @content_module.id
  end

  def has_didactic_content?
    Task.where(group_id: @participant.active_group.id,
               bit_core_content_module_id: module_id)
      .first
      .has_didactic_content?
  end
end
