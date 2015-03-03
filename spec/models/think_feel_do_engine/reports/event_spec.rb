require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Event do
      fixtures :all

      def data
        @data ||= Event.all
      end

      describe ".all" do
        context "when no events occurred" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(data).to be_empty
          end
        end

        context "when events occurred" do
          it "returns accurate summaries" do
            event = event_capture_events(:event_capture_events_010)

            expect(data.count).to eq 152
            expect(data).to include(
              participant_id: "TFD-1111",
              emitted_at: event.emitted_at.iso8601,
              current_url: "http://localhost:3000/navigator/modules/" \
                           "437912910/providers/426024276/1",
              headers: ["home", "Landing", "It's simple."],
              kind: "click"
            )
          end
        end
      end
    end
  end
end
