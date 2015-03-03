require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe ActivitiesHelper, type: :helper do
    fixtures :participants, :activity_types

    def activity(attrs)
      Activity.new(actual_pleasure_intensity: attrs[:actual],
                   predicted_pleasure_intensity: attrs[:predicted],
                   actual_accomplishment_intensity: attrs[:actual_accomplishment],
                   predicted_accomplishment_intensity: attrs[:predicted_accomplishment],
                   is_reviewed: attrs[:is_reviewed] || false,
                   participant: participants(:participant1),
                   activity_type: activity_types(:jogging))
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

    describe "no activities exist" do
      describe "percent_complete_message" do
        it "returns 'NA' in the message if no activities were scheduled" do
          expect(percent_complete_message(Activity)).to eq "Completion Score: Not Available (No activities were scheduled.)"
        end
      end
    end

    describe "activities exist" do
      describe "daily summary information" do
        before :each do
          activity(predicted: 1, predicted_accomplishment: 4).save
          activity(
            predicted: 1,
            predicted_accomplishment: 4,
            actual: 1,
            actual_accomplishment: 4,
            is_reviewed: true
          ).save
        end

        describe "percent_complete_message" do
          it "returns a message detailing percent complete" do
            expect(percent_complete_message(Activity)).to eq "Completion Score: 50% (You completed 1 out of 2 activities that you scheduled.)"
          end
        end

        describe "percent_complete" do
          it "to return a integer of how many activities were reviewed_and_completed out of how many were planned" do
            expect(percent_complete(Activity)).to eq 50
          end
        end

        describe "scheduled_count" do
          it "returns a total count of activities 'planned' and 'reviewed and completed'" do
            expect(scheduled_count(Activity)).to eq 2
          end
        end

        describe "scheduled_message" do
          it "returns the pluralized version of 'activity' depending on the count" do
            expect(scheduled_message(Activity)).to eq "2 activities"
          end
        end
      end
    end
  end
end
