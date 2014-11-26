require "spec_helper"

feature "Content Provider", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  before do
    sign_in_user users :admin1
    visit "/arms/#{arms(:arm1).id}/content_dashboard"
  end

  it "shoud have display a link to modules, slideshows, and lessons" do
    expect(page).to_not have_link "Tools"
    expect(page).to have_link "Module", href: "/arms/#{arms(:arm1).id}/bit_maker/content_modules"
    expect(page).to_not have_link "Providers"
    expect(page).to have_link "Slideshows", href: "/arms/#{arms(:arm1).id}/bit_maker/slideshows"
    expect(page).to have_link "Lessons", href: "/arms/#{arms(:arm1).id}/lessons"
  end
end