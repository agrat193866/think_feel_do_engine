require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe UserAgent do
      fixtures :all

      describe ".all" do
        context "when no events occurred" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(UserAgent.all).to be_empty
          end
        end

        context "when events occurred" do
          it "returns accurate summaries" do
            data = UserAgent.all

            expect(data.count).to eq 2
            expect(data).to include(
              participant_id: "TFD-1111",
              user_agent_family: "Chrome",
              user_agent_version: "40.0.2214",
              user_agent_os: "Mac OS X 10.10.2"
            )
          end
        end
      end
    end
  end
end
