module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant is active on the site for a period of time.
    class SiteSession
      THRESHOLD = 5.minutes

      def self.columns
        %w( participant_id sign_in_at first_action_at last_action_at )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          earliest_click_time = latest_click_time = nil
          times = click_times(participant.id)
          times.map do |click_time|
            earliest_click_time ||= click_time
            latest_click_time ||= earliest_click_time

            if click_time - latest_click_time < THRESHOLD &&
               click_time != times.last
              # this click is part of the current session
              latest_click_time = click_time

              nil
            else
              # this click is part of the next session or
              # it's the last click
              sign_in = preceding_sign_in(participant.id,
                                          earliest_click_time)
              session = {
                participant_id: participant.study_id,
                sign_in_at: sign_in.try(:iso8601),
                first_action_at: earliest_click_time.iso8601,
                last_action_at: latest_click_time.iso8601
              }
              earliest_click_time = latest_click_time = nil

              session
            end
          end.compact
        end.flatten
      end

      def self.click_times(participant_id)
        EventCapture::Event
          .where(participant_id: participant_id, kind: "click")
          .order(:emitted_at)
          .select(:emitted_at)
          .map(&:emitted_at)
      end

      # Returns the sign in for the Participant closest to the given time.
      def self.preceding_sign_in(participant_id, time)
        ParticipantLoginEvent
          .where(participant_id: participant_id)
          .order(:created_at)
          .where("created_at < ?", time)
          .last
          .try(:created_at)
      end
    end
  end
end
