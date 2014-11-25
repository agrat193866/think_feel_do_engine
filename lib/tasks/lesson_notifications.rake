require "rubygems"
require "twilio-ruby"

namespace :lesson_notifications do
  desc "triggers dialy email or sms notifications for newly available lesson material"
  task new_lessons: :environment do
    today = Time.now
    Group.all.each do |group|
      group.memberships.each do |membership|
        membership.learning_tasks.each do |task|
          if 0 == (today.to_date - membership.start_date.to_date).to_i
            if "email" == membership.participant.contact_preference
              puts "sending daily lesson notifications for #{Time.now.wday} on #{Time.now} for lesson module '#{task.bit_core_content_module.title}' to participant #{membership.participant.study_id}"
              ThinkFeelDoEngine::LessonNotificationMailer.lesson_notification_email(membership.participant, task.bit_core_content_module).deliver
            elsif "sms" == membership.participant.contact_preference
              # TODO: Pull this logic out into a seperate Gem
              recipient = membership.participant

              message_details = {
                from:
                  "#{ Rails.application.config.twilio_account_telephone_number }",
                to:
                  "+#{ recipient.phone_number }",
                body:
                  "Your next ThinkFeelDo lesson is available: #{task.bit_core_content_module.title}!"
              }

              if Rails.env.staging? || Rails.env.production?
                client = Twilio::REST::Client.new(
                  Rails.application.config.twilio_account_sid,
                  Rails.application.config.twilio_auth_token)
                account = client.account
                account.messages.create(message_details)
              else
                puts ("INFO - SMS attributes: " \
                  "#{ message_details }")
              end
            else
              puts "ERROR: could not send new lesson notification due to no contact_preference being set on participant #{membership.participant.study_id}"
            end
          end
        end
      end
    end
  end
end
