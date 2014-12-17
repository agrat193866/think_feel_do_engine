require "spec_helper"

feature "Lessons", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  context "Logged in as a content author" do

    before do
      sign_in_user users :content_author1
    end

    scenario "should see arm links" do
      visit "/arms"

      expect(page).to_not have_link "Researcher Dashboard"
      expect(page).to_not have_link "Coach Dashboard"
      expect(page).to have_link "Arm 1"
      expect(page).to have_link "Arm 2"
    end

    scenario "should see arm links" do
      visit "/arms"
      click_on "Arm 1"

      expect(page).to have_link "Manage Content"

      click_on "Manage Content"

      expect(page.current_path).to eq "/arms/#{arms(:arm1).id}/content_dashboard"
    end
  end
end
