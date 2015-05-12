require "rails_helper"

RSpec.describe "model lifecycle", type: :model do
  fixtures :all

  describe "Slides" do
    context "with associated MediaAccessEvents" do
      it "can be destroyed" do
        slide = BitCore::Slide.first
        MediaAccessEvent.create!(
          participant: Participant.first,
          slide: slide,
          media_type: "video",
          media_link: "//example.com"
        )
        slide.destroy!
      end
    end
  end
end
