require "spec_helper"

feature "send participant password reset instructions for participants who can access site", type: :feature do
  fixtures(:all)

  let(:participant) { participants(:participant1) }

  before { clear_emails }

  it "should redirect after password update", :js do
    allow_any_instance_of(ThinkFeelDoEngine::BrandHelper).to receive(:brand_location) { "#" }

    visit "/participants/sign_in"
    click_on "Forgot your password?"
    fill_in "Email", with: "participant1@example.com"
    click_on "Send me reset password instructions"

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."

    expect(last_email.to).to include(participant.email)
    path = extract_participant_password_edit_path_from_email
    visit path

    expect(page).to have_text "Change your password"

    fill_in("participant_password", with: "dog pig cat yeah!")
    fill_in("participant_password_confirmation", with: "dog pig cat yeah!")
    click_on "Change my password"

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq("/")
  end
end

feature "prevent password reset for participant blocked from the site", type: :feature do
  fixtures(:all)

  it "should redirect after password update", :js do
    allow_any_instance_of(ThinkFeelDoEngine::BrandHelper).to receive(:brand_location) { "#" }

    visit "/participants/sign_in"
    click_on "Forgot your password?"
    fill_in "Email", with: "inactive_participant@example.com"
    click_on "Send me reset password instructions"

    expect(current_path).to eq("/participants/sign_in")
    expect(page).to have_text "New password cannot be sent; this account is not active."
  end
end
