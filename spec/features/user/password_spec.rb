require "spec_helper"

feature "reset user password", type: :feature do
  fixtures(:all)

  let(:user) { users(:admin1) }

  before { clear_emails }

  it "should redirect after password update", :js do
    visit "/users/sign_in"
    click_on "Forgot your password?"
    fill_in "Email", with: "admin1@example.com"
    click_on "Send me reset password instructions"

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."

    last_email.to.should include(user.email)
    path = extract_password_edit_path_from_email
    visit path

    expect(page).to have_text "Change your password"

    fill_in("user_password", with: "dog pig cat yeah!")
    fill_in("user_password_confirmation", with: "dog pig cat yeah!")
    click_on "Change my password"

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq('/privacy_policy')
  end
end
