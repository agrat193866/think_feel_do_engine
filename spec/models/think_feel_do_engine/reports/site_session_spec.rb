require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe SiteSession do
      fixtures :all

      describe ".all" do
        context "when no sessions occurred" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(SiteSession.all).to be_empty
          end
        end

        context "when sessions occurred" do
          it "returns accurate summaries" do
            sign_in_event = participant_login_events(:participant1_001)
            first_action_event = event_capture_events(:event_capture_events_002)
            sign_out_event = event_capture_events(:event_capture_events_079)
            data = SiteSession.all

            expect(data.count).to eq 2
            expect(data).to include(
              participant_id: "TFD-1111",
              sign_in_at: sign_in_event.created_at.iso8601,
              first_action_at: first_action_event.emitted_at.iso8601,
              last_action_at: sign_out_event.emitted_at.iso8601
            )
          end
        end
      end
    end
  end
end
