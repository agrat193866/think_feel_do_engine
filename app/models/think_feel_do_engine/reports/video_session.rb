module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant plays a video.
    class VideoSession
      def self.columns
        %w( participant_id video_title video_started_at video_stopped_at
            stopping_action )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          video_play_events(participant.id).map do |e|
            m = e.current_url.match(/.*\/providers\/(\d+)\/(\d+)$/)
            provider_id = m ? m[1] : -1
            position = m ? m[2] : -1
            video = BitCore::ContentProvider
                    .where(id: provider_id)
                    .first
                    .try(:source_content)
                    .try(:slides)
                    .try(:find_by_position, position)
            next_e = next_event(e)

            {
              participant_id: participant.study_id,
              video_title: video.try(:title),
              video_started_at: e.emitted_at,
              video_stopped_at: next_e.try(:emitted_at),
              stopping_action: next_e.try(:kind)
            }
          end
        end.flatten
      end

      def self.video_play_events(participant_id)
        EventCapture::Event
          .where(participant_id: participant_id, kind: "videoPlay")
          .select(:participant_id, :kind, :emitted_at, :payload)
          .order(:emitted_at)
      end

      # Return the immediately following Event for the Participant that is not a
      # video play event, or nil if none exist.
      def self.next_event(event)
        stop_event = EventCapture::Event
                     .where(participant_id: event.participant_id)
                     .where.not(kind: "videoPlay")
                     .where("emitted_at > ?", event.emitted_at)
                     .select(:participant_id, :kind, :emitted_at)
                     .order(:emitted_at)
                     .limit(1)
                     .first

        return stop_event if stop_event.kind != "videoPause"

        # if the event is a pause and there's an immediately following finish,
        # return the finish event
        finish_event = EventCapture::Event
                       .where(participant_id: stop_event.participant_id)
                       .where("emitted_at > ? AND emitted_at < ?",
                              stop_event.emitted_at,
                              stop_event.emitted_at + 2.seconds)
                       .order(:emitted_at)
                       .limit(1)
                       .first

        finish_event.try(:kind) == "videoFinish" ? finish_event : stop_event
      end
    end
  end
end
