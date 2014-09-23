require "spec_helper"

module ThinkFeelDoEngine
  describe PhqAssessmentMailer do
    fixtures :participants, :users, :groups, :memberships

    context "reminder_email" do

      let(:mail) do
        PhqAssessmentMailer.reminder_email(participants(:participant1))
      end

      it "renders the headers" do
        expect(mail.subject).to eq("PHQ-9 Reminder")
        expect(mail.to).to eq([participants(:participant1).email])
        expect(mail.from).to eq(["stepped_care-no-reply@northwestern.edu"])
      end
    end
  end
end
