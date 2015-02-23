require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe LessonSlideView do
      fixtures :all

      describe ".all" do
        context "when no lesson slides were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(LessonSlideView.all).to be_empty
          end
        end

        context "when lesson slides were viewed" do
          it "returns accurate summaries" do
            data = LessonSlideView.all

            expect(data.count).to eq 2
          end
        end
      end
    end
  end
end
