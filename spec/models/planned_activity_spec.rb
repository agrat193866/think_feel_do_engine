require "rails_helper"

RSpec.describe PlannedActivity, type: :model do
  describe "validations" do
    it "requires the presence of predicted ratings" do
      planned_activity = PlannedActivity.new.tap(&:valid?)

      expect(planned_activity.errors[:predicted_accomplishment_intensity].size)
        .to eq(1)
      expect(planned_activity.errors[:predicted_pleasure_intensity].size)
        .to eq(1)
    end
  end
end
