require "rails_helper"

RSpec.describe Thought, type: :model do
  describe "#shared_description" do
    it "returns a thought description" do
      thought = Thought.new(content: "content")

      expect(thought.shared_description).to eq("Thought: content")
    end
  end

  describe "#status_label" do
    context "when no pattern or challenging thought have been assigned" do
      it "returns identified" do
        thought = Thought.new

        expect(thought.status_label).to eq Thought::IDENTIFIED
      end
    end

    context "when a pattern but no challenging thought is assigned" do
      it "returns assigned a pattern" do
        thought = Thought.new(pattern_id: 2323)

        expect(thought.status_label).to eq Thought::ASSIGNED_A_PATTERN
      end
    end

    context "when a challenging thought is assigned" do
      it "returns how the participant has amended the thought" do
        thought = Thought.new(challenging_thought: "content")

        expect(thought.status_label).to eq Thought::RESHAPED
      end
    end
  end
end
