require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ModulePageView do
      fixtures :all

      describe ".all" do
        context "when no module pages were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(ModulePageView.all.count).to eq 0
          end
        end

        context "when module pages were viewed" do
          it "returns accurate summaries" do
            select_event = event_capture_events(:event_capture_events_014)
            exit_event = event_capture_events(:event_capture_events_016)
            data = ModulePageView.all

            expect(data.count).to be >= 30
            expect(data).to include(
              participant_id: "TFD-1111",
              tool_id: bit_core_tools(:thought_tracker).id,
              module_id: bit_core_content_modules(:think_identifying).id,
              page_headers: ["THINK", "#1 Identifying",
                             "You are what you think...Your thoughts shape" \
                             " and guideThoughts are the exact sentences " \
                             "that go through your head."],
              page_selected_at: (select_event.emitted_at).iso8601,
              page_exited_at: (exit_event.emitted_at).iso8601,
              url: "http://localhost:3000/navigator/modules/954850709"
            )
          end
        end
      end
    end
  end
end
