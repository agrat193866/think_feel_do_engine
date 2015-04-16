require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe WaiAssessment do
      fixtures :all

      describe ".all" do
        context "when no assessments were taken" do
          it "returns an empty array" do
            ::WaiAssessment.destroy_all

            expect(WaiAssessment.all).to be_empty
          end
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            data = WaiAssessment.all

            expect(data.count).to eq 1
            expect(data).to include(
              participant_id: "TFD-1111",
              date_transmitted: Date.yesterday.iso8601,
              date_completed: Date.today.iso8601,
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
