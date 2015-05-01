require "rails_helper"

RSpec.describe AvailableContentModule, type: :model do
  fixtures :all

  describe ".bit_core_tool" do
    it "returns the associated Tool" do
      expect(AvailableContentModule.first.bit_core_tool)
        .to be_instance_of(BitCore::Tool)
    end
  end
end
