require "spec_helper"

feature "Lessons", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status, :coach_assignments
  )

  describe "Logged in as a clinician" do

    before do
      sign_in_user users :clinician1
    end

    scenario "should only see the arms - that through groups - have participants that the coach is assigned to" do
      visit "/arms"

      expect(page).to_not have_link "Researcher Dashboard"
      expect(page).to have_link "Coach Dashboard"
      expect(page).to have_link "Arm 1"
      expect(page).to have_link "Arm 2"
      expect(page).to_not have_link "Arm 4"

      sign_in_user users :user2
      visit "/arms"

      expect(page).to have_link "Arm 1"
      expect(page).to_not have_link "Arm 2"
      expect(page).to have_link "Arm 4"
    end

    scenario "should only see the groups of an arm that a coach is assigne to via coach_assignments" do
      visit "/arms/#{arms(:arm1).id}"

      expect(page).to have_link "Group 3"

      sign_in_user users :user2
      visit "/arms/#{arms(:arm1).id}"

      expect(page).to have_link "Group 1"
      expect(page).to_not have_link "Group 3"
    end
  end
end
