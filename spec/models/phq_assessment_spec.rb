require "rails_helper"

RSpec.describe PhqAssessment, type: :model do
  fixtures :all

  let(:valid_attributes) do
    {
      participant: Participant.first,
      release_date: Date.current,
      q1: 0,
      q2: 1,
      q3: 2,
      q8: 3
    }
  end

  describe "validation" do
    context "when the attributes are valid" do
      it "is valid" do
        expect(PhqAssessment.new(valid_attributes)).to be_valid
      end
    end

    context "when a response is below the minimum allowed" do
      it "is not valid" do
        expect(PhqAssessment.new(valid_attributes.merge(q4: -1))).not_to be_valid
      end
    end

    context "when a response is above the maximum allowed" do
      it "is not valid" do
        expect(PhqAssessment.new(valid_attributes.merge(q4: 4))).not_to be_valid
      end
    end
  end
end
