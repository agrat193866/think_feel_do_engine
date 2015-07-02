require "rails_helper"

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
      expect(page).to have_content(I18n.l(participants(:participant1)
                                            .messages
                                            .last.created_at, format: :standard))
    end
  end

  it "displays a received message" do
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
      expect(page).to have_content(I18n.l(participants(:participant1)
                                            .received_messages
                                            .last.created_at, format: :standard))
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

feature "visit route when no message id exists" do
  fixtures :all

  it "Should render alert and navigation message" do
    sign_in_participant participants(:participant1)
    visit "/navigator/modules/915512017/providers/392704088/1?context=MESSAGES&message_id=1"

    expect(page).to have_content "Message could not found. Click MESSAGES and try again."
  end
end

feature "no historical sent messages" do
  fixtures :all

  before do
    sign_in_participant participants(:participant3)
    visit "/navigator/contexts/MESSAGES"
  end

  it "shows the alert for no messages to display in the inbox" do
    within("#inbox") do
      expect(page).to have_content "No messages to display."
    end
  end

  it "should not show alert for no messages in sent box after sending message" do
    click_on "Compose"
    within("#new_message") do
      fill_in "message_subject", with: "test"
      fill_in "message_body", with: "test test test"
    end
    click_on "Send"

    within("#inbox") do
      expect(page).to have_content "No messages to display."
    end

    within("#sent") do
      expect(page).to have_content "test"
      expect(page).to_not have_content "No messages to display."
    end
  end
end

feature "inactive participants cannot compose messages" do
  fixtures :all

  before do
    sign_in_participant participants(:participant3)
    visit "/navigator/contexts/MESSAGES"
  end

  it "should not have a compose button on the message home" do
    expect(page).to_not have_button("Compose")
  end
end

feature "discontinued participants can continue messaging if arm settings allow it" do
  fixtures :all

  before do
    sign_in_participant participants(:participant_study_complete_2)
    visit "/navigator/contexts/MESSAGES"
  end

  it "should have a compose button on the message home" do
    expect(page).to have_link("Compose")
  end
end