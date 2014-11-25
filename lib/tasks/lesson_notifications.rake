namespace :lesson_notifications do

  desc "triggers dialy email or sms notifications for newly available lesson material"
  task new_lessons: :environment do
    today = Time.now
    Group.all.each do |group|
      group.memberships.each do |membership|
        membership.learning_tasks.each do |task|
          if 0 == (today.to_date - membership.start_date.to_date).to_i
            puts "sending daily lesson notifications for #{Time.now.wday} on #{Time.now} for lesson module '#{task.bit_core_content_module.title}' to participant #{membership.participant.study_id}"
            ThinkFeelDoEngine::LessonNotificationMailer.lesson_notification_email(membership.participant, task.bit_core_content_module).deliver
          end
        end
      end
    end
  end
end
