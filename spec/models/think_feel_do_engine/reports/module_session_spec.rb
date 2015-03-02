require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ModuleSession do
      fixtures :all

      describe ".all" do
        context "when no modules were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(ModuleSession.all).to be_empty
          end
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            first_render_event = event_capture_events(:event_capture_events_015)
            last_render_event = event_capture_events(:event_capture_events_015)
            data = ModuleSession.all

            expect(data.count).to eq 7
            expect(data).to include(
              participant_id: "TFD-1111",
              module_id: bit_core_content_modules(:think_identifying).id,
              page_headers: ["THINK", "#1 Identifying", "You are what you " \
                             "think...Your thoughts shape and guideThoughts " \
                             "are the exact sentences that go through your " \
                             "head."],
              module_selected_at: first_render_event.emitted_at.iso8601,
              last_page_number_opened: 1,
              last_page_opened_at: last_render_event.emitted_at.iso8601
            )
          end
        end
      end
    end
  end
end
