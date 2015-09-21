require "rails_helper"

module ThinkFeelDoEngine
  module LessonEvent
    RSpec.describe CompletionDataPresenter do
      let(:lesson) do
        instance_double(
          ContentModules::LessonModule,
          pretty_title: "bar")
      end
      let(:event) do
        {
          last_page_number_opened: 4,
          page_headers: ["foo", 8, "gas", "funk"]
        }
      end

      def lesson_viewing_event
        allow(ContentModules::LessonModule)
          .to receive(:find) { lesson }
        LessonEvent::CompletionDataPresenter
          .new(
            event: event,
            lesson_module: ContentModules::LessonModule)
      end

      describe "#last_page_number_opened" do
        it "displays the last page opened" do
          expect(lesson_viewing_event.last_page_number_opened)
            .to eq(4)
        end
      end

      describe "#page_headers" do
        it "displays the headers submitted in the event" do
          expect(lesson_viewing_event.page_headers)
            .to eq("gas")
        end
      end

      describe "#pretty_title" do
        it "delegates pretty title to the slide" do
          expect(lesson_viewing_event.pretty_title)
            .to eq("bar")
        end
      end
    end
  end
end
