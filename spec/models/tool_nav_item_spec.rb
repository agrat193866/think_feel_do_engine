require "spec_helper"
require_relative "../../app/models/tool_nav_item"

describe ToolNavItem do
  describe "#is_active?" do
    let(:participant) { double("participant") }
    let(:tool) { double("tool", id: 1) }

    subject { ToolNavItem.new(participant, tool) }

    it "returns true if the current module is in the tool" do
      tool_module = double("tool module", bit_core_tool_id: 1)
      expect(subject.is_active?(tool_module)).to eq true
    end

    it "returns false if the current module is not in the tool" do
      tool_module = double("tool module", bit_core_tool_id: 1000)
      expect(subject.is_active?(tool_module)).to eq false
    end
  end
end
