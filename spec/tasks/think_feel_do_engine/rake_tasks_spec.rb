require "spec_helper"
require "rake"

module ThinkFeelDoEngine
  describe "rake tasks" do
    fixtures :all

    # Some code taken from http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
    describe "email_reminders:phq_assessment" do

      let(:rake)      { Rake::Application.new }
      let(:task_path) { "../../lib/tasks/email_reminders" }
      subject         { Rake::Task["email_reminders:phq_assessment"] }

      def loaded_files_excluding_current_rake_file
        $LOADED_FEATURES.reject { |file| file == Rails.root.join("#{task_path}.rake").to_s }
      end

      before :each do
        Rake.application = rake
        Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)
        Rake::Task.define_task(:environment)
        PhqAssessmentMailer.deliveries = []
      end

      it "should send weekly emails to participants in study until their membership ends" do
        start_date = Date.current
        Timecop.travel(start_date.advance(days: 366))
        expect(Membership.active.count).to eq 2
        subject.reenable
        subject.invoke
        expect(PhqAssessmentMailer.deliveries.count).to eq 0
        (1..6).each do |d|
          Timecop.travel(start_date.advance(days: 366 + d))
          subject.reenable
          subject.invoke
        end
        expect(PhqAssessmentMailer.deliveries.count).to eq 1
        Timecop.travel(Date.current.advance(days: 1)) # 7 days later
        subject.reenable
        subject.invoke
        expect(PhqAssessmentMailer.deliveries.count).to eq 1
        (1..6).each do
          Timecop.travel(Time.current + (1.day))
          expect(Membership.active.count).to eq 1
          subject.reenable
          subject.invoke
        end
        expect(PhqAssessmentMailer.deliveries.count).to eq 2
        Timecop.travel(Time.current + (1.day)) # 14 days later
        expect(Membership.active.count).to eq 0
        subject.reenable
        subject.invoke
        expect(PhqAssessmentMailer.deliveries.count).to eq 2
        (1..6).each do
          Timecop.travel(Time.current + (1.day))
          expect(Membership.active.count).to eq 0
          subject.reenable
          subject.invoke
          expect(PhqAssessmentMailer.deliveries.count).to eq 2 # No new emails
        end
        Timecop.travel(Time.current + (1.day)) # 21 days later
        expect(Membership.active.count).to eq 0
        subject.reenable
        subject.invoke
        expect(PhqAssessmentMailer.deliveries.count).to eq 2 # No new emails
      end
    end
  end
end
