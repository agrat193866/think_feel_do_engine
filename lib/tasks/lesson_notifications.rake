require "rubygems"
require "twilio-ruby"

namespace :lesson_notifications do
  desc "triggers dialy email or sms notifications for newly available lesson material"
  task new_lessons: :environment do
    puts "STARTING: lesson_notifications:new_lessons task"
    today = Time.now
    Membership.active.each do |membership|
      membership.task_statuses.each do |task_status|
        if task_status.is_lesson? && task_status.notify_today?
          if task_status.participant.notify_by_email?
            puts "sending daily lesson notifications for #{Time.now.wday} on #{Time.now} for lesson module '#{task_status.task.bit_core_content_module.title}' to participant #{membership.participant.study_id}"
            ThinkFeelDoEngine::LessonNotificationMailer.lesson_notification_email(task_status.participant, task_status.task.bit_core_content_module).deliver
          elsif task_status.participant.notify_by_sms?
            recipient = task_status.participant
            message_details = {
              from:
                "#{ Rails.application.config.twilio_account_telephone_number }",
              to:
                "+#{ recipient.phone_number }",
              body:
                "Your next ThinkFeelDo lesson is available: #{task_status.task.bit_core_content_module.title}!"
            }

            if Rails.env.staging? || Rails.env.production?
              client = Twilio::REST::Client.new(
                Rails.application.config.twilio_account_sid,
                Rails.application.config.twilio_auth_token)
              account = client.account
              account.messages.create(message_details)
            else
              puts ("INFO - SMS attributes: #{ message_details }")
            end
          else
            puts "ERROR: could not send new lesson notification due to  no contact_preference being set on participant #{task_status.participant.study_id}"
          end
        end
      end
    end
    puts "ENDING: lesson_notifications:new_lessons task"
  end
end
