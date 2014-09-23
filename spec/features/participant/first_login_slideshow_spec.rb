require "spec_helper"

feature "first login slideshow" do
  fixtures :all

  context "on first login" do
    before do
      sign_in_participant participants(:participant1)
    end

    it "should display the first slide of the 'Home Intro' slideshow" do
      expect(page).to have_text "Welcome to ThiFeDo"
    end
  end

  context "on second login" do
    before do
      sign_in_participant participants(:participant1)
      sign_in_participant participants(:participant1)
    end

    it "should display the home page" do
      expect(page).not_to have_text "Welcome to ThiFeDo"
      expect(page).to have_link "Replay Introduction"
    end
  end
end
