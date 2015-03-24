require "rails_helper"

RSpec.describe Activity do
  fixtures :all

  describe "#shared_description" do
    let(:participant) { participants(:participant1) }
    it "returns an item description" do
      thought = Thought
                .new(participant: participant,
                     effect: "harmful",
                     content: "content")
      expect(thought.shared_description).to eq("Thought: content")
    end
  end

  describe "#status_label" do
    let(:participant) { participants(:participant1) }
    it "returns how the participant has amended the thought" do
      thought = Thought
                .new(participant:
                       participant,
                     effect: "harmful",
                     content: "content")
      expect(thought.status_label).to eq("Identified")

      thought = Thought
                .new(participant: participant,
                     effect: "harmful",
                     content: "content", pattern_id: 2323)
      expect(thought.status_label).to eq("Assigned a pattern to")

      thought = Thought
                .new(participant: participant,
                     effect: "harmful",
                     challenging_thought: "content")
      expect(thought.status_label).to eq("Reshaped")
    end
  end
end
