require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe SiteMessageMailer, type: :mailer do
    fixtures :all

    describe "general" do
      let(:message) do
        double("message",
               participant: participants(:participant2),
               subject: "foo",
               body: "bar")
      end
      let(:mail) { SiteMessageMailer.general(message) }

      it "renders the headers" do
        expect(mail.subject).to eq("foo")
        expect(mail.to).to eq([participants(:participant2).email])
        expect(mail.from).to eq(["stepped_care-no-reply@northwestern.edu"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("bar")
      end
    end
  end
end
