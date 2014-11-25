require "spec_helper"

module ThinkFeelDoEngine
  describe LessonNotificationMailer do
    fixtures :participants, :users, :groups, :memberships, :tasks, :"bit_core/content_modules"

    context "lesson notification_email" do

      let(:mail) do
        LessonNotificationMailer.lesson_notification_email(participants(:participant1), bit_core_content_modules(:slideshow_content_module_1))
      end

      it "renders the headers" do
        expect(mail.subject).to eq("New Lesson Available")
        expect(mail.to).to eq([participants(:participant1).email])
        expect(mail.from).to eq(["stepped_care-no-reply@northwestern.edu"])
      end
    end
  end
end
