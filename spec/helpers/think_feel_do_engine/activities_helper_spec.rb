require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe ActivitiesHelper, type: :helper do
    def activity(attrs)
      Activity.new(actual_pleasure_intensity: attrs[:actual],
                   predicted_pleasure_intensity: attrs[:predicted])
    end

    describe "#average_intensity_difference" do
      it "returns message when no actual and predicted pairs exist" do
        [
          [],
          [activity(actual: 2), activity(predicted: 7)]
        ].each do |activities|
          expect(helper.average_intensity_difference(activities, "pleasure"))
            .to eq "No activities exist."
        end
      end

      it "returns the average when pairs exist" do
        [
          [activity(actual: 1, predicted: 2), activity(actual: 6, predicted: 5)],
          [activity(actual: 7, predicted: 8), activity(actual: 2, predicted: 3)]
        ].each do |activities|
          expect(helper.average_intensity_difference(activities, "pleasure"))
            .to eq 1
        end

        [
          [activity(actual: 5, predicted: 5)],
          [activity(actual: 7, predicted: 7), activity(actual: 2, predicted: 2)]
        ].each do |activities|
          expect(helper.average_intensity_difference(activities, "pleasure"))
            .to eq 0
        end
      end
    end
  end
end
