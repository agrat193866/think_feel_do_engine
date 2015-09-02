module ThinkFeelDoEngine
  module Presenters
    # Simplifies the logic of the media/audio access event views.
    class MediaAccessEvent
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def completed?
        end_time
      end

      def day_available
        time_since_task_relased
          .to_date.to_s(:user_date)
      end

      def duration
        end_time - created_at
      end

      def end_datetime
        end_time.to_s(:standard) unless completed?
      end

      def since_task_relased
        time_since_task_relased.to_time.to_i
      end

      def started
        created_at.to_s(:standard)
      end

      def title
        event.slide_title
      end

      private

      def created_at
        event.created_at
      end

      def end_time
        event.end_time
      end

      def start_date
        event.participant.active_membership.start_date
      end

      def time_since_task_relased
        start_date + event.task_release_day - 1
      end
    end
  end
end
