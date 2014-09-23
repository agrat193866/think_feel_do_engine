require "spec_helper"

feature "admin dashboard" do
  fixtures(:users, :user_roles)

  context "particpants" do

    before do
      sign_in_user users :admin1
      visit "/admin/participant"
    end

    it "creates a participant without a study Id" do
      expect(Participant.find_by(email: "test@ex.co")).to be_nil
      expect(page).not_to have_content "test@ex.co"
      click_on "Add new"
      fill_in "Study Id", with: ""
      fill_in "Password", with: "secrets!withExtraEntropy"
      fill_in "Password confirmation", with: "secrets!withExtraEntropy"
      fill_in "Email", with: "test@ex.co"
      click_on "Save"

      expect(page).not_to have_content "test@ex.co"
      expect(Participant.find_by(email: "test@ex.co")).not_to be_nil
    end

    it "creates a participant with a study Id" do
      expect(page).not_to have_content "testID123"
      click_on "Add new"
      fill_in "Study Id", with: "testID123"
      fill_in "Password", with: "secrets!withExtraEntropy"
      fill_in "Password confirmation", with: "secrets!withExtraEntropy"
      fill_in "Email", with: "test@ex.co"
      click_on "Save"
      expect(page).to have_content "testID123"
    end
  end
end
