require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ModuleSession do
      fixtures :all

      describe ".all" do
        context "when no modules were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(ModuleSession.all).to be_empty
          end
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            data = ModuleSession.all

            expect(data.count).to eq 7
          end
        end
      end
    end
  end
end
