require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Login do
      fixtures :all

      describe ".all" do
        context "when no logins recorded" do
          it "returns an empty array" do
            ParticipantLoginEvent.destroy_all

            expect(Login.all).to be_empty
          end
        end

        context "when logins recorded" do
          it "returns accurate summaries" do
            data = Login.all
            login_event = participant_login_events(:participant1_001)
            participant = participants(:participant1)
            expect(data.count).to be >= 1
            expect(data).to include(
              participant_id: participant.study_id,
              occurred_at: login_event.created_at.iso8601
            )
          end
        end
      end
    end
  end
end
