require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe EmotionalRating do
      fixtures :all

      describe ".all" do
        context "when no thoughts recorded" do
          it "returns an empty array" do
            Emotion.destroy_all

            expect(EmotionalRating.all).to be_empty
          end
        end

        context "when thoughts recorded" do
          it "returns accurate summaries" do
            data = EmotionalRating.all
            emotional_rating = emotional_ratings(:longing)
            participant = participants(:participant1)
            expect(data.count).to eq 6
            expect(data).to include(
              participant_id: participant.study_id,
              name: emotional_rating.name,
              rating: emotional_rating.rating,
              created_at: emotional_rating.created_at.iso8601
            )
          end
        end
      end
    end
  end
end