require "rails_helper"

RSpec.describe Thought, type: :model do
  let(:password) { SecureRandom.hex }
  let(:participant) do
    Participant.create!(password: password,
                        password_confirmation: password,
                        email: "e@foo.bar")
  end

  describe "normalization" do
    it "converts empty challenging thoughts to nil" do
      thought = Thought.new(challenging_thought: " ").tap(&:valid?)

      expect(thought.challenging_thought).to be_nil
    end

    it "converts empty act as if statements to nil" do
      thought = Thought.new(act_as_if: " ").tap(&:valid?)

      expect(thought.act_as_if).to be_nil
    end
  end

  describe ".unreflected" do
    it "returns harmful Thoughts no challenging thought or no act as if" do
      attributes = {
        participant: participant,
        content: "c",
        effect: Thought::EFFECTS[:harmful]
      }
      thought1 = Thought.create!(attributes.merge(challenging_thought: "ct"))
      thought2 = Thought.create!(attributes.merge(act_as_if: "aai"))
      Thought.create!(attributes.merge(challenging_thought: "ct",
                                       act_as_if: "aai"))

      expect(Thought.unreflected).to eq [thought1, thought2]
    end
  end

  describe ".last_seven_days" do
    it "returns Thoughts created during the last 7 days" do
      attributes = {
        participant: participant,
        content: "c",
        effect: Thought::EFFECTS[:harmful]
      }
      Thought.create!(attributes.merge(created_at: DateTime.now - 8.days))
      thought2 = Thought.create!(
        attributes.merge(created_at: DateTime.now - 7.days))
      thought3 = Thought.create!(attributes.merge(created_at: DateTime.now))

      expect(Thought.last_seven_days).to eq [thought2, thought3]
    end
  end

  describe ".for_day" do
    it "returns Thoughts created within the same day as the timestamp" do
      attributes = {
        participant: participant,
        content: "c",
        effect: Thought::EFFECTS[:helpful]
      }
      thought1 = Thought.create!(attributes.merge(created_at: DateTime.now))
      Thought.create!(attributes.merge(created_at: DateTime.now - 1.day))
      Thought.create!(attributes.merge(created_at: DateTime.now + 1.day))

      expect(Thought.for_day(DateTime.now)).to eq [thought1]
    end
  end

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
