require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe PatientThought do
      fixtures :all

      describe ".all" do
        context "when no thoughts recorded" do
          it "returns an empty array" do
            Thought.destroy_all

            expect(PatientThought.all).to be_empty
          end
        end

        context "when thoughts recorded" do
          it "returns accurate summaries" do
            data = PatientThought.all
            thought = thoughts(:participant1_harmful)
            participant = participants(:participant1)
            expect(data.count).to eq 5
            expect(data).to include(
              participant_id: participant.study_id,
              content: thought.content,
              created_at: thought.created_at.iso8601
            )
          end
        end
      end
    end
  end
end