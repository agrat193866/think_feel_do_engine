require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe LessonViewing do
      fixtures :all

      describe ".all" do
        context "when no lessons were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(LessonViewing.all.count).to eq 0
          end
        end

        context "when lessons were viewed" do
          it "returns accurate summaries" do
            event = event_capture_events(:event_capture_events_169)
            data = LessonViewing.all

            expect(data.count).to eq 2
            expect(data).to include(
              participant_id: "TFD-1111",
              lesson_id: bit_core_content_modules(:video_lesson_slideshow).id,
              page_headers: ["LEARN", "Learn - Video Slideshow", "Meet Jim"],
              lesson_selected_at: (event.emitted_at).utc.iso8601,
              last_page_number_opened: 1,
              last_page_opened_at: (event.emitted_at).utc.iso8601
            )
          end
        end
      end
    end
  end
end
