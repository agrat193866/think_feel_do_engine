module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant clicks, causes a page to render,
    # starts/pauses/finishes a video, etc.
    class Event
      def self.columns
        %w( participant_id emitted_at current_url headers kind )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          EventCapture::Event.where(participant_id: participant.id)
            .map do |event|
            {
              participant_id: participant.study_id,
              emitted_at: event.emitted_at.iso8601,
              current_url: event.current_url,
              headers: event.headers,
              kind: event.kind
            }
          end
        end.flatten
      end

      def self.to_csv
        Reporter.new(self).write_csv
      end
    end
  end
end
