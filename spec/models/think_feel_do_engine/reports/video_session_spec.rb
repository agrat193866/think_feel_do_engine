require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe VideoSession do
      fixtures :all

      describe ".all" do
        context "when no videos were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(VideoSession.all).to be_empty
          end
        end

        context "when videos were viewed" do
          it "returns accurate summaries" do
            video_start_1 = event_capture_events(:event_capture_events_170)
            video_stop_1 = event_capture_events(:event_capture_events_171)
            video_start_2 = event_capture_events(:event_capture_events_172)
            video_stop_2 = event_capture_events(:event_capture_events_173)
            video_start_3 = event_capture_events(:event_capture_events_174)
            video_stop_3 = event_capture_events(:event_capture_events_176)
            data = VideoSession.all

            expect(data.count).to eq 3
            expect(data).to include(
              participant_id: "TFD-1111",
              video_title: "Meet Jim",
              video_started_at: (video_start_1.emitted_at).utc.iso8601,
              video_stopped_at: (video_stop_1.emitted_at).utc.iso8601,
              stopping_action: "videoPause"
            )
            expect(data).to include(
              participant_id: "TFD-1111",
              video_title: "Meet Jim",
              video_started_at: (video_start_2.emitted_at).utc.iso8601,
              video_stopped_at: (video_stop_2.emitted_at).utc.iso8601,
              stopping_action: "videoPause"
            )
            expect(data).to include(
              participant_id: "TFD-1111",
              video_title: "Meet Jim",
              video_started_at: (video_start_3.emitted_at).utc.iso8601,
              video_stopped_at: (video_stop_3.emitted_at).utc.iso8601,
              stopping_action: "videoFinish"
            )
          end
        end
      end
    end
  end
end
