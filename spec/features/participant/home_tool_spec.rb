require "rails_helper"

feature "home tool", type: :feature do
  fixtures(
    :arms, :participants, :users,
    :groups, :memberships, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools",
    :"bit_core/content_modules", :"bit_core/content_providers"
  )

  it "has the correct content" do
    sign_in_participant participants(:participant2)
    visit "/"

    expect(page).to have_text "It's simple"

    click_on "Next"

    expect(page).to have_text "Log in once a day"

    click_on "Next"

    expect(page).to have_text "Come back every day"

    click_on "Next"

    # video page

    click_on "Next"

    expect(page).to have_text("It's simple")
  end
end
