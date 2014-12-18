require "spec_helper"

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
  end
end
