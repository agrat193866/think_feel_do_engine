module ThinkFeelDoEngine
  # Simplifies the logic of the media/audio access event views.
  class MediaAccessEventPresenter
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def completed?
      end_time
    end

    def date_when_available
      date_of_release
        .to_s(:user_date)
    end

    def duration_of_session
      end_time - created_at
    end

    def formatted_end_time
      end_time.to_s(:standard)
    end

    def formatted_start_time
      created_at.to_s(:standard)
    end

    def sortable
      created_at.to_i
    end

    def title
      event.slide_title
    end

    private

    def created_at
      event.created_at
    end

    def date_of_release
      start_date + (event.task_release_day - 1)
    end

    def end_time
      event.end_time
    end

    def start_date
      event.participant.active_membership.start_date
    end
  end
end
