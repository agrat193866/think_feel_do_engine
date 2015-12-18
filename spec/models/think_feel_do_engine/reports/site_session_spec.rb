require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe SiteSession do
      fixtures :all

      def data
        @data ||= SiteSession.all
      end

      describe ".all" do
        context "when no sessions occurred" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(data).to be_empty
          end
        end

        context "when sessions occurred" do
          it "returns accurate summaries" do
            sign_in_event = participant_login_events(:participant1_001)
            first_action_event = event_capture_events(:event_capture_events_002)
            sign_out_event = event_capture_events(:event_capture_events_079)

            expect(data.count).to be >= 1
            expect(data).to include(
              participant_id: "TFD-1111",
              sign_in_at: sign_in_event.created_at.iso8601,
              first_action_at: first_action_event.emitted_at.iso8601,
              last_action_at: sign_out_event.emitted_at.iso8601
            )
          end
        end

        context "when no preceding sign in can be found" do
          it "returns partial data" do
            ParticipantLoginEvent.destroy_all
            first_action_event = event_capture_events(:event_capture_events_002)
            sign_out_event = event_capture_events(:event_capture_events_079)

            expect(data.count).to be >= 1
            expect(data).to include(
              participant_id: "TFD-1111",
              sign_in_at: nil,
              first_action_at: first_action_event.emitted_at.iso8601,
              last_action_at: sign_out_event.emitted_at.iso8601
            )
          end
        end

        context "when a single event exists" do
          it "returns a single session" do
            sign_in_event = participant_login_events(:participant1_001)
            EventCapture::Event.destroy_all
            first_action_event = EventCapture::Event.create!(
              participant: participants(:participant1),
              kind: "click",
              emitted_at: DateTime.now - 5000.seconds
            )

            expect(data.count).to eq 1
            expect(data).to include(
              participant_id: "TFD-1111",
              sign_in_at: sign_in_event.created_at.iso8601,
              first_action_at: first_action_event.emitted_at.iso8601,
              last_action_at: first_action_event.emitted_at.iso8601
            )
          end
        end
      end
    end
  end
end
