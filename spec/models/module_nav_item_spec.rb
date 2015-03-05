require "rails_helper"

describe ModuleNavItem do
  fixtures :all

  let(:participant) { participants(:participant1) }
  let(:modules) { BitCore::ContentModule }
  let(:ts1) { task_status(:task_status1) }
  let(:task1_module) { ts1.task.bit_core_content_module }

  it ".for_content_modules returns content modules that only have a position greater than 0" do
    expect(modules.all.map(&:position)).to include(1)

    module_positions =  ModuleNavItem
                        .for_content_modules(participant, modules)
                        .map do |nav_item|
                          modules
                          .find(nav_item.module_id)
                          .position
                        end

    expect(module_positions).to_not include(1)
  end

  it ".task_status returns the most recent task status for a participant and a module" do
    nav_item = ModuleNavItem.new(participant, task1_module)
    expect(nav_item.task_status.id).to eq ts1.id
  end
end