# Uses Rails' mail preview feature.
class MailPreview < ActionMailer::Preview
  def new_for_coach
    coach = User.first
    MessageNotifications.new_for_coach(coach)
  end

  def new_for_participant
    participant = Participant.first
    MessageNotifications.new_for_participant(participant)
  end

  def phq_reminder_email
    participant = Participant.first
    PhqAssessmentMailer.reminder_email(participant)
  end
end
