require "spec_helper"

feature "login page", type: :feature do
  before { visit "/users/sign_in" }

  it "should not display 'Remember me'" do
    expect(page).not_to have_text "Remember me"
  end
end
