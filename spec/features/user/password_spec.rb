require "rails_helper"

feature "reset user password", type: :feature do
  fixtures(:all)

  let(:user) { users(:admin1) }

  before { clear_emails }

  it "should redirect after password update", :js do
    allow_any_instance_of(ThinkFeelDoEngine::BrandHelper).to receive(:brand_location) { "#" }

    visit "/users/sign_in"
    click_on "Forgot your password?"
    fill_in "Email", with: "admin1@example.com"
    click_on "Send me reset password instructions"

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."

    expect(last_email.to).to include(user.email)
    path = extract_password_edit_path_from_email
    visit path

    expect(page).to have_text "Change your password"

    password = "1Dog pig cat yeah!"
    fill_in "New password", with: password
    fill_in "Confirm new password", with: password
    click_on "Change my password"

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq("/privacy_policy")
  end
end
