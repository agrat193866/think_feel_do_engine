require "spec_helper"

feature "Privacy Policy", :js, type: :feature do
  it "not obscured in the footer" do
    visit "/participants/sign_in"
    click_on "Privacy Policy"

    expect(page).to have_text("Privacy Policy")
  end

  it "is accessible by any visitor" do
    visit "/privacy_policy"

    expect(page).to have_text("Privacy Policy")
  end
end