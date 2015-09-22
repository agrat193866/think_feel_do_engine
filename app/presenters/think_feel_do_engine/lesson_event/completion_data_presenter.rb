module ThinkFeelDoEngine
  module LessonEvent
    # Creates a presenter for the logic of the completion data partial
    class CompletionDataPresenter
      attr_reader :event, :lesson_module

      def initialize(event:, lesson_module:)
        @event = event
        @lesson_module = lesson_module
      end

      def last_page_number_opened
        event[:last_page_number_opened]
      end

      def last_page_opened_at
        DateTime.iso8601(event[:last_page_opened_at])
      end

      def page_headers
        event[:page_headers].try do |page_headers|
          page_headers[2]
        end
      end

      def pretty_title
        lesson.pretty_title
      end

      def selected_at
        DateTime.iso8601(event[:lesson_selected_at])
      end

      private

      def lesson
        lesson_module.find(event[:lesson_id])
      end
    end
  end
end
