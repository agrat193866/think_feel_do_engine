module ThinkFeelDoEngine
  module Reports
    # Scenario: Participants complete a Phq Assessment by email.
    class PhqAssessment
      def self.columns
        %w( participant_id date_transmitted date_completed phq1 phq2 phq3 phq4
            phq5 phq6 phq7 phq8 phq9 )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          participant.phq_assessments.map do |assessment|
            {
              participant_id: participant.study_id,
              date_transmitted: assessment.release_date.iso8601,
              date_completed: assessment.updated_at.to_date.iso8601,
              phq1: assessment.q1,
              phq2: assessment.q2,
              phq3: assessment.q3,
              phq4: assessment.q4,
              phq5: assessment.q5,
              phq6: assessment.q6,
              phq7: assessment.q7,
              phq8: assessment.q8,
              phq9: assessment.q9
            }
          end
        end.flatten
      end
    end
  end
end
