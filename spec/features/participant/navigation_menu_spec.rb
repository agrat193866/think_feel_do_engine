require "spec_helper"

feature "Participant navigation menu", type: :feature do
  fixtures :all

  before { sign_in_participant participants(:participant1) }

  it "highlights the current tool" do
    visit "/navigator/contexts/DO"

    expect(page).to have_css "#main li.DO.active"
    expect(page).not_to have_css "#main li.FEEL.active"

    click_on "Tracking Your Mood"

    expect(page).not_to have_css "#main li.DO.active"
    expect(page).to have_css "#main li.FEEL.active"
  end
end
