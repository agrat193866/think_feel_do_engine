require "rails_helper"

module ThinkFeelDoEngine
  module LessonEvent
    RSpec.describe CompletionDataPresenter do
      let(:event) do
        {
          page_headers: ["foo", 8, "gas", "funk"]
        }
      end

      def lesson_viewing_event
        LessonEvent::CompletionDataPresenter
          .new(
            event: event,
            lesson_module: ContentModules::LessonModule)
      end

      describe "#page_headers" do
        it "displays the headers submitted in the event" do
          expect(lesson_viewing_event.page_headers)
            .to eq("gas")
        end
      end
    end
  end
end
