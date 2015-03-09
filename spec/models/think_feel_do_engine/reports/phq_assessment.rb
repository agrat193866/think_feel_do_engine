require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe PhqAssessmentReport do
      fixtures :all

      describe ".all" do
        context "when no phq assessments occurred" do
          it "returns an empty array" do
            ::PhqAssessment.destroy_all

            expect(PhqAssessmentReport.all).to be_empty
          end
        end

        context "when phq assessments occurred" do
          it "returns accurate summaries" do
            data = PhqAssessmentReport.all

            expect(data.count).to eq 2
          end
        end
      end
    end
  end
end
