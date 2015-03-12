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
end
