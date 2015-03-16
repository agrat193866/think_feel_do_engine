module ThinkFeelDoEngine
  module Reports
    # Collect metadata for all Participant Thoughts.
    class PatientThought
      def self.columns
        %w( participant_id content created_at )
      end

      def self.all
        Participant.select(:id, :study_id).map.map do |participant|
          participant.thoughts.map do |thought|
            {
              participant_id: participant.study_id,
              content: thought.content,
              created_at: thought.created_at.iso8601
            }
          end
        end.flatten
      end
    end
  end
end
