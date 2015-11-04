require "rails_helper"

module ThinkFeelDoEngine
  describe MessageNotifications do
    fixtures :all

    context "coach creates mail" do
      let(:clinician) { users(:clinician1) }
      let(:mail) { MessageNotifications.new_for_coach(clinician, groups(:group1)) }

      it "renders the headers" do
        expect(mail.subject).to eq("New message")
        expect(mail.to).to eq([clinician.email])
        expect(mail.from).to eq(["stepped_care-no-reply@northwestern.edu"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("You have a new message")
      end

      it "includes the correct access messaging link" do
        expect(mail.body.encoded).to include "/coach/groups/#{groups(:group1).id}/messages"
      end
    end

    context "participant is sent email notification" do
      describe "when participant messaging tool is titled 'MESSAGES'" do
        let(:participant) { participants(:participant1) }
        let(:mail) { MessageNotifications.new_for_participant(participant) }

        it "renders the headers" do
          expect(mail.subject).to eq("New message")
          expect(mail.to).to eq([participant.email])
          expect(mail.from).to eq(["stepped_care-no-reply@northwestern.edu"])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match("You have a new message")
        end

        it "includes the correct reference link to the messaging tool" do
          expect(mail.body.encoded).to include "/navigator/contexts/MESSAGES"
        end
      end

      describe "when participant messaging tool is NOT titled 'MESSAGES'" do
        let(:participant) { participants(:active_participant) }
        let(:mail) { MessageNotifications.new_for_participant(participant) }

        it "includes the correct reference link to the messaging tool" do
          expect(mail.body.encoded).to include "/navigator/contexts/G%20MAIL"
        end
      end
    end
  end
end
