module ThinkFeelDoEngine
  module Reports
    # Collect metadata for each Participant Activity.
    class PatientActivity
      def self.columns
        %w( participant_id activity_title created_at )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          participant.activities.map do |activity|
            {
              participant_id: participant.study_id,
              activity_title: activity.title,
              created_at: activity.created_at.iso8601
            }
          end
        end.flatten
      end
    end
  end
end