module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant logs into the site.
    class Login
      def self.columns
        %w( participant_id occurred_at )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          ParticipantLoginEvent
            .where(participant_id: participant.id).map do |event|
              {
                participant_id: participant.study_id,
                occurred_at: event.created_at.iso8601
              }
            end
        end.flatten
      end
    end
  end
end
