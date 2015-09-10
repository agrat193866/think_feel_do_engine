module ThinkFeelDoEngine
  # Simplifies the logic of the media/audio access event views.
  class MediaAccessEventPresenter
    attr_reader :event, :start_date

    def initialize(event:, start_date:)
      @event = event
      @start_date = start_date
    end

    def completed
      end_time
    end

    def available_on
      relased_on
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
      relased_on.to_time.to_i
    end

    def title
      event.slide_title
    end

    private

    def created_at
      event.created_at
    end

    def relased_on
      start_date + (event.task_release_day - 1)
    end

    def end_time
      event.end_time
    end
  end
end
