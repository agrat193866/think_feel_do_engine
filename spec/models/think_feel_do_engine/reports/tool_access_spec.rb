require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ToolAccess do
      fixtures :all

      describe ".all" do
        context "when no tools were accessed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(ToolAccess.all).to be_empty
          end
        end

        context "when tools were accessed" do
          it "returns accurate summaries" do
            data = ToolAccess.all

            expect(data.count).to eq 6
          end
        end
      end
    end
  end
end
