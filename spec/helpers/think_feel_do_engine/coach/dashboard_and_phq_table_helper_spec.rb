require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    RSpec.describe DashboardAndPhqTableHelper, type: :helper do
      describe "#init_summary_styles" do
        let(:summary) { { step?: true, stay?: nil, release?: nil, upper_limit: 17, lower_limit: 0, current_week: 5, range_start: 5 } }

        it "No longer sets `prev_range_start`" do
          helper.init_summary_styles(range_start: 5)

          expect(helper.respond_to?(:prev_range_start)).to eq(false)
        end

        it "returns label with text and label class" do
          helper.init_summary_styles(summary)

          expect(helper.result_span(helper.step_string, helper.step_label))
            .to match(/<span class="label label-danger label-adj_danger">True<\/span>/)
        end
      end
    end
  end
end
