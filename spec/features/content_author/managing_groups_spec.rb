require "spec_helper"

feature "managing groups", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  it "displays group names" do
    sign_in_user users :admin1
    visit "/arms/#{groups(:group1).arm_id}/manage/groups/#{groups(:group1).id}/edit_tasks"

    expect(page).to have_text("Manage Task Group 1")
  end
end
