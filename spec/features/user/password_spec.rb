require "rails_helper"

feature "reset user password", type: :feature do
  fixtures :all

  let(:valid_password) { "1Dog pig cat yeah!" }

  before do
    clear_emails
    visit "/users/sign_in"
    navigate_to_change_password_page
  end

  it "should redirect after password update", :js do
    fill_in "New password", with: valid_password
    fill_in "Confirm new password", with: valid_password

    click_on "Change my password"

    expect(page).to have_text "Your password has been changed successfully. You are now signed in."
    expect(current_path).to eq "/privacy_policy"
  end

  context "displays the correct password strength" do
    it "displays 'Weak' with no password given", :js do
      within "#password-strength .text-danger" do
        expect(page).to have_text "Weak"
      end
    end

    it "displays 'Medium' with a medium entropy password", :js do
      fill_in "New password", with: "1Dog ca!"
      fill_in "Confirm new password", with: "1Dog ca!"

      within "#password-strength .text-primary" do
        expect(page).to have_text "Medium"
      end
    end

    it "shows 'Strong' with a strong entropy password", :js do
      fill_in "New password", with: valid_password
      fill_in "Confirm new password", with: valid_password

      within "#password-strength .text-success" do
        expect(page).to have_text "Strong"
      end
    end

    it "shows \"password can't be blank\" when password is deleted", :js do
      fill_in "New password", with: valid_password
      fill_in "Confirm new password", with: valid_password

      within "#password-strength .text-success" do
        expect(page).to have_text "Strong"
      end

      fill_in "New password", with: ""
      click_on "Change my password"

      expect(page).to have_text "Password can't be blank"
    end
  end

  def navigate_to_change_password_page
    click_on "Forgot your password?"

    within "h2" do
      expect(page).to have_text "Forgot your password"
    end

    fill_in "Email", with: "admin1@example.com"
    click_on "Send me reset password instructions"

    expect(page).to have_text "You will receive an email with instructions on how to reset your password in a few minutes."
    expect(last_email.to).to include(users(:admin1).email)

    visit extract_password_edit_path_from_email

    expect(page).to have_text "Change your password"
  end
end
