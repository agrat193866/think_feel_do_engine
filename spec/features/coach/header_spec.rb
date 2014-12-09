require "spec_helper"

feature "header", type: :feature do
  fixtures :users, :user_roles

  describe "Logged in as a clinician" do

    before do
      sign_in_user users :clinician1
    end

    it "should display a log out link" do
      expect(page).to have_selector("a[href=\"/users/sign_out\"]")
    end
  end
end
