module ThinkFeelDoEngine
  # Sends a PHQ9 email reminder to a given participant.
  class PhqAssessmentMailer < ActionMailer::Base
    default from: "stepped_care-no-reply@northwestern.edu"

    def reminder_email(participant)
      @participant = participant
      @participant_token = ParticipantToken.create(
        participant_id: participant.id,
        token_type: "phq9",
        release_date: Date.current
      )

      mail(to: @participant.email,
           subject: "PHQ-9 Reminder")
    end
  end
end
