require "rails_helper"

describe ParticipantToken do
  it "generates a token value" do
    token = ParticipantToken.new.tap(&:valid?)

    expect(token.token).not_to be_nil
  end
end
