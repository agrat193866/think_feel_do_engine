require "spec_helper"

feature "participant tool availability", type: :feature do
  fixtures :all

  before { sign_in_participant participants(:active_participant) }

  it "all assigned modules should be accessible in other arms", js: true do
    within "#main" do
      click_on "THOUGHT"
      click_on "THOUGHT Home"
    end

    expect(page).to have_text "Content Module Think landing"
  end
end
