require "rails_helper"

RSpec.describe WaiAssessment, type: :model do
  fixtures :participants

  let(:valid_attributes) do
    {
      q1: 1, q3: 4, q4: 5, q5: 2, q7: 2, q8: 3, q9: 1, q10: 5, q11: 2, q12: 4,
      release_date: Date.today,
      participant: participants(:participant1)
    }
  end

  subject(:wai_assessment) { WaiAssessment.create!(valid_attributes) }

  describe "validations" do
    it "prevents invalid scores" do
      wai_assessment.q3 = 0

      expect(wai_assessment).not_to be_valid

      wai_assessment.q3 = 4
      wai_assessment.q5 = 6

      expect(wai_assessment).not_to be_valid
    end
  end
end
