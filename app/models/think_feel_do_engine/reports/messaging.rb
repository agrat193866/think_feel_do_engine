module ThinkFeelDoEngine
  module Reports
    # Metadata for Coach-Participant messaging.
    class Messaging
      COACH = 1
      PARTICIPANT = 2

      def self.columns
        %w( message_id study_id therapist_id sender_id sender recipient
            start_dt treatment_week day event_date event_time
            is_message_opened message_opened_at message_subject
            message_content )
      end

      def self.all
        Message.all.map do |message|
          new(message).report
        end
      end

      def initialize(message)
        @message = message
        @sender = message.sender
        @recipient = message.recipient
        @participant = @sender.is_a?(Participant) ? @sender : @recipient
        @coach = @sender.is_a?(User) ? @sender : @recipient
      end

      def report
        {
          message_id: @message.id,
          study_id: study_id,
          therapist_id: coach_id,
          sender_id: sender_type,
          sender: sender_identifier,
          recipient: recipient_identifier,
          start_dt: participant_start_date,
          treatment_week: enrollment_week,
          day: enrollment_day,
          event_date: date_sent,
          event_time: time_sent.iso8601,
          is_message_opened: is_message_read?,
          message_opened_at: message_read_at.try(:iso8601),
          message_subject: @message.subject,
          message_content: @message.body
        }
      end

      private

      def study_id
        @participant.study_id
      end

      def coach_id
        @coach.email
      end

      def sender_type
        @sender == @coach ? COACH : PARTICIPANT
      end

      def sender_identifier
        @sender == @coach ? coach_id : study_id
      end

      def recipient_identifier
        @recipient == @coach ? coach_id : study_id
      end

      def participant_start_date
        @participant_start_date ||=
          @participant.active_membership.try(:start_date)
      end

      def enrollment_week
        enrollment_day && ((enrollment_day - 1).days / 1.week) + 1
      end

      def enrollment_day
        @enrollment_day ||= (
          participant_start_date &&
            (time_sent.to_date - participant_start_date + 1).to_i
        )
      end

      def date_sent
        @message.sent_at.to_date.to_s(:db)
      end

      def time_sent
        @message.sent_at
      end

      def is_message_read?
        received_message.try(:is_read)
      end

      def message_read_at
        is_message_read? && received_message.try(:updated_at)
      end

      def received_message
        @received_message ||= @recipient.received_messages
                              .find_by_message_id(@message.id)
      end
    end
  end
end
