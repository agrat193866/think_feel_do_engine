require "spec_helper"

feature "messages" do
  fixtures(
    :all
  )

  before do
    sign_in_participant participants(:participant1)
    visit "/navigator/contexts/MESSAGES"
  end

  it "allows a participant to compose and submit a new message" do
    click_on("Compose")
    fill_in("Subject", with: "some new message")
    fill_in("Message", with: "some body")
    click_on("Send")

    expect(page).to have_text("Message saved")
  end

  it "allows a participant to reply to a message", :js do
    expect(page).to_not have_content("Reply: Try out the LEARN tool")
    page.find("#inbox a").trigger("click")
    # click_on "Try out the LEARN tool"

    click_on "Reply"

    expect(page).to have_content("I think you will find it helpful")
    expect(page).to have_content("To Coach")

    fill_in("Message", with: "some body")
    click_on "Send"

    expect(page).to have_text("Message saved")

    click_on "Sent"

    expect(page).to have_content("To: Coach")
    expect(page).to have_content("Reply: Try out the LEARN tool")
    within "#sent" do
      expect(page).to have_content(participants(:participant1).messages.last.created_at.to_formatted_s(:date_time_with_meridian))
    end
  end

  it "displays a recieved message" do
    click_on "Try out the LEARN tool"

    expect(page).to have_content("Try out the LEARN tool")
    expect(page).to have_content("From Coach")
    expect(page).to have_content("To You")
    expect(page).to have_content("I think you will find it helpful")
  end

  it "displays the number of unread messages in the inbox" do
    expect(page).to have_text("Inbox (1)")
  end

  it "displays all messages" do
    expect(page).to have_text("Try out the LEARN tool")
    expect(page).to have_text("I like this app")
    within "#inbox" do
      expect(page).to have_content(participants(:participant1).received_messages.last.created_at.to_formatted_s(:date_time_with_meridian))
    end
  end

  it "shows a message" do
    click_on("I like this app")

    expect(page).to have_text("This app is really helpful!")
  end

  it "does not display the Compose button for inactive participants" do
    sign_in_participant participants(:inactive_participant)
    visit "/navigator/contexts/MESSAGES"

    expect(page).not_to have_text("Compose")
  end
end
