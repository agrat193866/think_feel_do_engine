require "spec_helper"

feature "reset user password", type: :feature do
  fixtures(:all)

  let(:user) { users(:admin1) }

  before(:each) do
    clear_emails
  end

  it "should redirect to arms path after password update", :js do
    visit "/users/sign_in"
    click_link("Forgot your password")
    fill_in("user_email", with: "admin1@example.com")
    click_button("Send me reset password instructions")

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."

    last_email.to.should include(user.email)
    path = extract_password_edit_path_from_email
    visit path

    expect(page).to have_text "Change your password"
    fill_in("user_password", with: "dog pig cat yeah!")
    fill_in("user_password_confirmation", with: "dog pig cat yeah!")
    click_button("Change my password")

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq("/arms")
  end
end
