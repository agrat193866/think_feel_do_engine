require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe PatientActivity do
      fixtures :all

      describe ".all" do
        context "when no thoughts recorded" do
          it "returns an empty array" do
            Activity.destroy_all

            expect(PatientActivity.all).to be_empty
          end
        end

        context "when thoughts recorded" do
          it "returns accurate summaries" do
            data = PatientActivity.all
            activity = activities(:planned_activity1)
            participant = participants(:participant1)
            expect(data.count).to eq 18
            expect(data).to include(
              participant_id: participant.study_id,
              activity_title: activity.title,
              created_at: activity.created_at.iso8601
            )
          end
        end
      end
    end
  end
end