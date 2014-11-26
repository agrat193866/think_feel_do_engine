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
    visit "/arms/#{arms(:arm1).id}/bit_maker/content_providers/#{bit_core_content_providers(:awake_period_form_provider).id}"
  end

  it "shoud have display a link to modules - not providers" do
    expect(page).to have_text "Content Provider"
    expect(page).to have_text "#1 Awareness"
    expect(page).to_not have_link "Providers"
    expect(page).to have_link "Module", href: "/arms/#{arms(:arm1).id}/bit_maker/content_modules/#{bit_core_content_modules(:do_awareness).id}"
  end
end