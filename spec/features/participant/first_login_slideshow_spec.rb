require "spec_helper"

feature "first login slideshow" do
  fixtures :all

  context "on first login" do
    before do
      sign_in_participant participants(:participant1)
    end

    it "should display the home page" do
      expect(page).not_to have_text "Welcome to ThiFeDo"
      expect(page).to have_link "Replay Intro"
    end
  end
end
