require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    RSpec.describe DashboardAndPhqTableHelper, type: :helper do
      describe "#init_summary_styles" do
        it "No longer sets `prev_range_start`" do
          helper.init_summary_styles(range_start: 5)

          expect(helper.prev_range_start)
            .to be_nil
        end
      end
    end
  end
end
