namespace :email_reminders do

  desc "triggers weekly PHQ email reminder"
  task phq_assessment: :environment do
    day_of_the_week = Time.now.wday
    Membership.active.each do |membership|
      if (membership.start_date.wday == day_of_the_week) && (membership.start_date != Date.today)
        puts "sending weekly PHQ email reminders for day #{Time.now.wday} on #{Time.now} to participant #{membership.participant.study_id}"
        ThinkFeelDoEngine::PhqAssessmentMailer.reminder_email(membership.participant).deliver
      end
    end
  end
end
