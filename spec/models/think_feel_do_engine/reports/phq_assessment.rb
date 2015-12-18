require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe PhqAssessment do
      fixtures :all

      describe ".all" do
        context "when no phq assessments occurred" do
          it "returns an empty array" do
            ::PhqAssessment.destroy_all

            expect(Reports::PhqAssessment.all).to be_empty
          end
        end

        context "when phq assessments occurred" do
          it "returns accurate summaries" do
            data = Reports::PhqAssessment.all
            phq = phq_assessments(:participant_phq1_a)

            expect(data.count).to be >= 1
            expect(data).to include(
              participant_id: phq.participant.study_id,
              date_transmitted: phq.release_date.iso8601,
              date_completed: phq.updated_at.to_date.iso8601,
              phq1: phq.q1,
              phq2: phq.q2,
              phq3: phq.q3,
              phq4: phq.q4,
              phq5: phq.q5,
              phq6: phq.q6,
              phq7: phq.q7,
              phq8: phq.q8,
              phq9: phq.q9
            )
          end
        end
      end
    end
  end
end
