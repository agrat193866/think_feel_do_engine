require "rails_helper"

feature "coach messages", type: :feature do
  fixtures :all

  describe "Logged in as a clinician" do
    let(:group1) { groups(:group1) }
    let(:participant1) { participants(:participant1) }
    let(:participant2) { participants(:participant2) }
    let(:participant3) { participants(:participant3) }
    let(:delivered_message1) { delivered_messages(:participant_to_coach1) }

    before do
      sign_in_user users :clinician1
      visit "/coach/groups/#{group1.id}/messages"
    end

    it "allows Coach to search to assigned Participant" do
      select(participant1.study_id, from: "search")
      click_on "Search"

      expect(page).to have_content delivered_message1.subject
    end

    it "doesn't allow Coach to search for unassigned Participant" do
      expect(page).not_to have_selector("option", text: participant2.study_id)
    end

    it "doesn't allow Coach to search for non-Group Participant" do
      expect(page).not_to have_selector("option", text: participant3.study_id)
    end

    it "doesn't display links not authorize to the user" do
      expect(page).not_to have_link("Admin")
      expect(page).not_to have_link("Groups")
      expect(page).not_to have_link("Slideshows")
    end

    it "displays study id but not email addresses of patients" do
      expect(page).not_to have_content(participant1.email)
      expect(page).to have_content("TFD-1111")

      last_message = users(:clinician1).received_messages.last

      within "#inbox" do
        expect(page).to have_content(last_message.created_at.to_s(:short))
      end
    end

    it "allows a coach to compose and submit a new message" do
      click_on("Compose")

      expect(page).not_to have_text(participant1.email)

      select("TFD-1111", from: "To")
      fill_in("Subject", with: "some new message")
      fill_in("Message", with: "some body")
      click_on("Send")

      expect(page).to have_content("Message saved")
      expect(ActionMailer::Base.deliveries.last.subject).to eq "New message"
    end

    it "doesn't allow Coach to compose message to an unassigned Participant" do
      click_on "Compose"

      expect(page).not_to have_selector("option", text: participant2.study_id)
    end

    it "doesn't allow Coach to compose message to non-Group Participant" do
      click_on "Compose"

      expect(page).not_to have_selector("option", text: participant3.study_id)
    end

    it "delivers an SMS when the Participant has that preference" do
      expect(participants(:participant3).contact_preference).to eq "sms"

      visit "/coach/groups/#{groups(:group3).id}/messages"
      click_on("Compose")
      select("TFD-33303", from: "To")
      fill_in("Subject", with: "some new message")
      fill_in("Message", with: "some body")
      click_on("Send")

      expect(page).to have_content("Message saved")
      expect(MessageSmsNotification.messages.last[:to]).to eq "+1-608-215-2391"
    end

    it "allows a coach to reply to a message" do
      click_on "I like this app"
      click_on "Reply"
      fill_in("Message", with: "some body")
      click_on("Send")

      expect(page).to have_content("Message saved")

      click_on "Sent"

      expect(page).to have_content("Reply: I like this app")

      last_message = users(:clinician1).messages.last

      within "#inbox" do
        expect(page).to have_content(last_message.created_at.to_s(:short))
      end
      click_on "Reply: I like this app"

      expect(page).to have_content("From You")
      expect(page).to have_content("To TFD-1111")
    end

    it "allows a coach to compose and submit a new message with module links" do
      click_on("Compose")
      select("TFD-1111", from: "To")
      fill_in("Subject", with: "Message with link")
      fill_in("Message", with: "Try this link out:")
      click_on("Send")
      sign_in_participant participant1
      visit "/navigator/contexts/MESSAGES"
      click_on "Message with link"

      expect(page).to have_content "Try this link out:"
    end

    it "doesn't allow coach to send message without selecting a participant" do
      click_on "Compose"
      fill_in("Subject", with: "Message with link")
      fill_in("Message", with: "Try this link out:")
      click_on("Send")

      expect(page)
        .to have_content "Unable to save message: Recipient can't be blank"
    end

    it "displays a sent message" do
      click_on "Try out the LEARN tool"

      expect(page).to have_content("Try out the LEARN tool")
      expect(page).to have_content("From You")
      expect(page).to have_content("To TFD-1111")
      expect(page).to have_content("I think you will find it helpful")
    end

    it "displays messages for a coach from their participants" do
      click_on delivered_message1.subject

      expect(page)
        .to have_content delivered_message1.body
    end

    it "doesn't display messages from other coaches' participants" do
      forbidden_email_subject = delivered_messages(:participant_to_coach2).subject

      expect(page).to_not have_content(forbidden_email_subject)
    end

    it "doesn't display another coach's participants' emails for composing messages" do
      CoachAssignment.create(coach_id: users(:user2).id,
                             participant_id: participants(:participant2).id)
      click_on("Compose")

      expect(page).to_not have_content(participants(:participant2).email)
    end
  end
end
