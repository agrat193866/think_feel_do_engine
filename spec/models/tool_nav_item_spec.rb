require "rails_helper"

describe ToolNavItem do
  describe "#is_active?" do
    let(:participant) { double("participant") }
    let(:content_module) { double("module", id: 1) }
    let(:tool) { double("tool", content_modules: [content_module]) }

    subject { ToolNavItem.new(participant, tool) }

    it "returns true if the current module is in the tool" do
      tool_module = double("tool module", id: 1)
      expect(subject.is_active?(tool_module)).to eq true
    end

    it "returns false if the current module is not in the tool" do
      tool_module = double("tool module", id: 1000)
      expect(subject.is_active?(tool_module)).to eq false
    end
  end
end
