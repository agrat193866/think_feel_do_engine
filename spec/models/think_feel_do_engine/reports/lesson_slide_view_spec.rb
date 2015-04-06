require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe LessonSlideView do
      fixtures :all

      describe ".all" do
        context "when no lesson slides were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(LessonSlideView.all).to be_empty
          end
        end

        context "when lesson slides were viewed" do
          it "returns accurate summaries" do
            data = LessonSlideView.all
            participant = participants(:participant1)
            lesson = bit_core_content_modules(:slideshow_content_module_2)
            slide = bit_core_slides(:do_awareness_intro1)
            select_event = event_capture_events(:event_capture_events_064)
            exit_event = event_capture_events(:event_capture_events_108)

            expect(data.count).to eq 2
            expect(data).to include(
              participant_id: participant.study_id,
              lesson_id: lesson.id,
              slide_id: slide.id,
              slide_title: slide.title,
              slide_selected_at: select_event.emitted_at.iso8601,
              slide_exited_at: exit_event.emitted_at.iso8601
            )
          end
        end
      end
    end
  end
end
