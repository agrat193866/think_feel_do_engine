require "spec_helper"

class MockMessage
  include Addressable
end

describe Addressable do
  let(:message) { MockMessage.new }

  before do
    allow(message).to receive(:sender) { sender }
    allow(message).to receive(:recipient) { recipient }
    allow(message).to receive(:recipient_id) { recipient.id }
  end

  describe "#from" do
    let(:sender) { double("sender", id: 123) }
    let(:recipient) { double("recipient", id: 456) }

    it "labels You" do
      expect(message.from(sender)).to eq "You"
    end

    it "labels the sender Participant" do
      allow(sender).to receive(:study_id) { "stud123" }

      expect(message.from).to eq "stud123"
    end

    it "labels the Coach" do
      allow(CoachAssignment).to receive(:exists?)
      .with(participant_id: recipient.id, coach_id: sender.id)
      .and_return(true)

      expect(message.from).to eq "Coach"
    end

    it "labels the Moderator" do
      expect(message.from).to eq "Moderator"
    end
  end

  describe "#to" do
    let(:recipient) { double("recipient", id: 123) }
    let(:sender) { double("sender", id: 456) }

    it "labels You" do
      expect(message.from(sender)).to eq "You"
    end

    it "labels the recipient Participant" do
      allow(recipient).to receive(:study_id) { "stud456" }

      expect(message.to).to eq "stud456"
    end

    it "labels the Coach" do
      allow(CoachAssignment).to receive(:exists?)
      .with(participant_id: sender.id, coach_id: recipient.id)
      .and_return(true)

      expect(message.to).to eq "Coach"
    end

    it "labels the Moderator" do
      expect(message.to).to eq "Moderator"
    end
  end
end
