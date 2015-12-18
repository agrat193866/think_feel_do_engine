require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe TaskCompletion do
      fixtures :all

      describe ".all" do
        context "when no tasks were completed" do
          it "returns an empty array" do
            TaskStatus.destroy_all

            expect(TaskCompletion.all).to be_empty
          end
        end

        context "when tasks were completed" do
          it "returns accurate summaries" do
            data = TaskCompletion.all

            expect(data.count).to be >= 1
            expect(data).to include(
              participant_id: "TFD-1111",
              title: "#1 Identifying",
              completed_on: Date.today.iso8601
            )
          end
        end
      end
    end
  end
end
