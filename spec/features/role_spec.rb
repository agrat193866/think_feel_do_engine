require "rails_helper"

feature "users notified about their role status", type: :feature do
  fixtures :users

  context "Non-admin user without a role" do
    it "should display all messages" do
      sign_in_user users(:user_without_role)

      expect(page).to have_text "We're sorry, but you need to have a role to continue"
      expect(page).to have_text "Contact your administrator"
    end
  end
end