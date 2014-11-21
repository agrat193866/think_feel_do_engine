require "spec_helper"

feature "managing groups" do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  it "displays group names" do
    sign_in_user users :admin1
    visit "/manage/groups"
    expect(page).to have_text("Group Without Creator")
  end

  it "displays learning content for each group" do
    sign_in_user users :admin1
    visit "/manage/groups"
    with_scope "#group-#{groups(:group1).id}" do
      click_on "Learning Content"
    end

    expect(page).to have_text "Learning Content"
    expect(page).to have_text "Group 1"
    expect(page).to have_text "Do - Awareness Introduction"
    expect(page).to have_text "This is just the beginning..."
    expect(page).to have_text "For the next few days, let's start by"
    expect(page).to have_text "Do - Planning Introduction"
    expect(page).to have_text "The last few times you were here..."
    expect(page).to have_text "You told us about a few activities that were either fun or importan"
  end
end
