require "rails_helper"

feature "send participant password reset instructions for participants who can access site", type: :feature do
  fixtures(:all)

  let(:participant) { participants(:participant1) }
  let(:valid_password) { "1Dog pig cat yeah!" }

  before do
    clear_emails
    visit "/participants/sign_in"
  end

  it "should redirect after password update", :js do
    navigate_to_change_password_page

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."
    expect(last_email.to).to include(participant.email)

    visit extract_participant_password_edit_path_from_email

    expect(page).to have_text "Change your password"

    fill_in "New password", with: valid_password
    fill_in "Confirm new password", with: valid_password

    expect { click_on "Change my password" }
      .to change { participant.participant_login_events.count }.by(1)

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq "/"
  end

  context "validates password", :js do
    it "shows \"Weak\" for no password given" do
      navigate_to_change_password_page
      visit extract_participant_password_edit_path_from_email

      expect(page).to have_text "Change your password"
      within "#password-strength .text-danger" do
        expect(page).to have_text "Weak"
      end
    end

    it "shows \"Medium\" for password of medium strength" do
      navigate_to_change_password_page
      visit extract_participant_password_edit_path_from_email

      fill_in "New password", with: "1Dog ca!"
      fill_in "Confirm new password", with: "1Dog ca!"

      within "#password-strength .text-primary" do
        expect(page).to have_text "Medium"
      end
    end

    it "shows \"Strong\" for password of strong strength" do
      navigate_to_change_password_page
      visit extract_participant_password_edit_path_from_email

      fill_in "New password", with: valid_password
      fill_in "Confirm new password", with: valid_password

      within "#password-strength .text-success" do
        expect(page).to have_text "Strong"
      end
    end

    it "shows error message when password is removed" do
      navigate_to_change_password_page
      visit extract_participant_password_edit_path_from_email

      fill_in "New password", with: ""
      click_on "Change my password"

      expect(page).to have_text "Password can't be blank"
    end
  end
end

feature "prevent password reset for participant blocked from the site", type: :feature do
  fixtures(:all)

  it "should redirect after password update", :js do
    allow_any_instance_of(ThinkFeelDoEngine::BrandHelper).to receive(:brand_location) { "#" }

    visit "/participants/sign_in"
    click_on "Forgot your password?"

    within "h2" do
      expect(page).to have_text "Forgot your password"
    end

    fill_in "Email", with: "inactive_participant@example.com"
    click_on "Send me reset password instructions"

    expect(current_path).to eq "/participants/sign_in"
    expect(page).to have_text "New password cannot be sent; this account is not active."
  end
end

def navigate_to_change_password_page
  click_on "Forgot your password?"

  within "h2" do
    expect(page).to have_text "Forgot your password"
  end

  fill_in "Email", with: "participant1@example.com"
  click_on "Send me reset password instructions"
end