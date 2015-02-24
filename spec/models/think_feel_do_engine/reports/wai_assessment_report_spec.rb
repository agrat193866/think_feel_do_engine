require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe WaiAssessmentReport do
      fixtures :all

      describe ".all" do
        context "when no assessments were taken" do
          it "returns an empty array" do
            WaiAssessment.destroy_all

            expect(WaiAssessmentReport.all).to be_empty
          end
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            data = WaiAssessmentReport.all

            expect(data.count).to eq 1
            expect(data).to include(
              participant_id: "TFD-1111",
              date_transmitted: Date.yesterday,
              date_completed: Date.today,
              wai1: 2,
              wai2: 3,
              wai3: 1,
              wai4: 2,
              wai5: 3,
              wai6: 1,
              wai7: 2,
              wai8: 3,
              wai9: 1,
              wai10: 2,
              wai11: 3,
              wai12: 1
            )
          end
        end
      end
    end
  end
end
