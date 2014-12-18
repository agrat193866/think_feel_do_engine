require "spec_helper"

feature "coach messages", type: :feature do
  fixtures(
    :arms, :users, :user_roles, :participants,
    :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :coach_assignments,
    :messages, :groups, :memberships, :tasks, :task_status, :moods,
    :phq_assessments, :emotions, :delivered_messages)

  describe "Logged in as a clinician" do
    let(:group1) { groups(:group1)}

    before do
      sign_in_user users :clinician1
      visit "/coach/groups/#{group1.id}/messages"
    end

    it "doesn't display links not authorize to the user" do
      expect(page).not_to have_link("Admin")
      expect(page).not_to have_link("Groups")
      expect(page).not_to have_link("Slideshows")
    end

    it "displays study id but not email addresses of patients" do
      expect(page).not_to have_content("participant1@example.com")
      expect(page).to have_content("TFD-1111")
      with_scope "#inbox" do
        expect(page).to have_content(users(:clinician1).received_messages.last.created_at.to_formatted_s(:short))
      end
    end

    it "allows a coach to compose and submit a new message" do
      click_on("Compose")
      expect(page).not_to have_text("participant1@example.com")
      select("TFD-1111", from: "To")
      fill_in("Subject", with: "some new message")
      fill_in("Message", with: "some body")
      click_on("Send")

      expect(page).to have_content("Message saved")
      expect(ActionMailer::Base.deliveries.last.subject).to eq "New message"
    end

    it "delivers an SMS when the Participant has that preference" do
      participants(:participant3).update(contact_preference: "sms")

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
      with_scope "#inbox" do
        expect(page).to have_content(users(:clinician1).messages.last.created_at.to_formatted_s(:short))
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
      sign_in_participant participants(:participant1)
      visit "/navigator/contexts/MESSAGES"
      click_on "Message with link"
      expect(page).to have_content "Try this link out:"
    end

    it "displays a sent message" do
      click_on "Try out the LEARN tool"

      expect(page).to have_content("Try out the LEARN tool")
      expect(page).to have_content("From You")
      expect(page).to have_content("To TFD-1111")
      expect(page).to have_content("I think you will find it helpful")
    end

    it "displays messages for a coach from their participants" do
      click_on delivered_messages(:participant_to_coach1).subject

      expect(page).to have_content delivered_messages(:participant_to_coach1).body
    end

    it "doesn't display messages from other coach's participants" do
      expect(page).to_not have_content(delivered_messages(:participant_to_coach2).subject)
    end

    it "doesn't display another coach's participants' emails for composing messages" do
      CoachAssignment.create(coach_id: users(:user2).id, participant_id: participants(:participant2).id)
      click_on("Compose")

      expect(page).to_not have_content(participants(:participant2).email)
    end
  end
end
