require "rails_helper"

describe DeliveredMessage do
  fixtures :all

  let(:arm) { arms(:arm5) }
  let(:participant) { participants(:participant3) }
  let(:clinician) { users(:clinician1) }
  let(:message) { messages(:participant3_to_clinician1) }

  it ".sent_from returns messages sent from someone specific" do
    expect(DeliveredMessage.sent_from(participant.id).count).to eq 0

    DeliveredMessage.create(
      recipient_id: clinician.id,
      recipient_type: "User",
      message: message)

    expect(DeliveredMessage.sent_from(participant.id).count).to eq 1
  end
end