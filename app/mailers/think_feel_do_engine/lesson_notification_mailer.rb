module ThinkFeelDoEngine
  # Sends a new lesson notification to a given participant.
  class LessonNotificationMailer < ActionMailer::Base
    default from: "stepped_care-no-reply@northwestern.edu"

    def lesson_notification_email(participant, lesson_module)
      @participant = participant
      @lesson = lesson_module
      mail(to: @participant.email,
           subject: "New Lesson Available")
    end
  end
end
