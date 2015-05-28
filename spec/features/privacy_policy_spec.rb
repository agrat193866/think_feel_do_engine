require "rails_helper"

feature "Privacy Policy", :js, type: :feature do
  fixtures :all

  it "not obscured in the footer" do
    visit "/participants/sign_in"
    click_on "Privacy Policy"

    expect(page).to have_text("Privacy Policy")
  end

  it "is accessible by any visitor" do
    visit "/privacy_policy"

    expect(page).to have_text("Privacy Policy")
  end

  it "should not show navbar for unauthenticated participants" do
    expect(page).to_not have_css("#navbar-collapse")
  end

  context "participant is logged in" do
    let(:participant1) { participants(:participant1) }

    before :each do
      sign_in_participant participant1
      visit "/privacy_policy"
    end

    it "should show navbar for authenticated participants" do
      expect(page).to have_css("#navbar-collapse")
    end
  end
end