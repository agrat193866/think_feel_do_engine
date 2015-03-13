module ThinkFeelDoEngine
  module Reports
    # Collect metadata for all Participant Emotional Ratings.
    class EmotionalRating
      def self.columns
        %w( participant_id name rating created_at )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          participant.emotional_ratings.map do |emotional_rating|
            {
              participant_id: participant.study_id,
              name: emotional_rating.name,
              rating: emotional_rating.rating,
              created_at: emotional_rating.created_at.iso8601
            }
          end
        end.flatten
      end
    end
  end
end
