require "spec_helper"

feature "Lessons", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  describe "Logged in as a clinician" do

    before do
      sign_in_user users :clinician1
    end

    scenario "should see arm links" do
      visit "/arms"

      expect(page).to_not have_link "Researcher Dashboard"
      expect(page).to have_link "Coach Dashboard"
      expect(page).to_not have_link "Arm 1"
    end
  end
end
