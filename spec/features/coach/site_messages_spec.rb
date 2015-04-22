require "rails_helper"

feature "Site messages", type: :feature do
  fixtures :all

  it "permits sending messages to participants" do
    sign_in_user users :clinician1
    visit "/coach/groups/#{groups(:group1).id}/site_messages/new"
    select participants(:participant1).study_id, from: "Participant"
    fill_in "Subject", with: "one weird trick"
    fill_in "Body", with: "blah blah blah"
    click_on "Send"

    expect(ActionMailer::Base.deliveries.last.to)
      .to include(participants(:participant1).email)

    visit "/coach/groups/#{groups(:group1).id}/site_messages"

    expect(page).to have_text "Subject"
    expect(page).to have_text "Body"
    expect(page).to have_text "Sent"
    expect(page).to have_text "one weird trick"
    expect(page).to have_text "blah blah blah"
    expect(page).to have_content I18n.l(Time.current, format: :standard)

    click_on "Show"

    expect(page).to have_text "Participant: TFD-1111"
    expect(page).to have_text "Subject: one weird trick"
    expect(page).to have_text "Body: blah blah blah"
  end
end
