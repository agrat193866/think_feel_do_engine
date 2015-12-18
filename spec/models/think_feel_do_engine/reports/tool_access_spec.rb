require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ToolAccess do
      fixtures :all

      describe ".all" do
        context "when no tools were accessed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(ToolAccess.all).to be_empty
          end
        end

        context "when tools were accessed" do
          it "returns accurate summaries" do
            data = ToolAccess.all
            participant = participants(:participant1)
            content_module = bit_core_content_modules(:think_identifying)
            event = event_capture_events(:event_capture_events_013)

            expect(data.count).to be >= 2
            expect(data).to include(
              participant_id: participant.study_id,
              module_title: content_module.title,
              came_from: "Tool home",
              occurred_at: event.emitted_at.iso8601
            )
          end
        end
      end
    end
  end
end
