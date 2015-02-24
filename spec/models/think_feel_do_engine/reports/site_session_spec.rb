require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe SiteSession do
      fixtures :all

      describe ".all" do
        context "when no sessions occurred" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(SiteSession.all).to be_empty
          end
        end

        context "when sessions occurred" do
          it "returns accurate summaries" do
            data = SiteSession.all

            expect(data.count).to eq 2
          end
        end
      end
    end
  end
end
