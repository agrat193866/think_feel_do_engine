require "rails_helper"

describe ModuleNavItem do
  fixtures :all

  let(:participant) { participants(:participant1) }
  let(:modules) { BitCore::ContentModule }

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
end