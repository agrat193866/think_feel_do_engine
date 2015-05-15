module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant starts viewing a Slide.
    class LessonSlideView
      include LessonModule

      def self.columns
        %w( participant_id lesson_id slide_id slide_title slide_selected_at
            slide_exited_at )
      end

      def self.all
        interactions = all_slide_interactions

        # condense adjacent interactions
        filtered_interactions = []
        interactions.each_with_index do |interaction, i|
          previous_interaction = i > 0 ? interactions[i - 1] : {}
          next if previous_interaction[:slide_id] == interaction[:slide_id]

          next_interaction = interactions[i + 1] || {}
          filtered_interaction = interaction.clone

          if next_interaction[:slide_id] == interaction[:slide_id]
            filtered_interaction[:slide_exited_at] =
              next_interaction[:slide_exited_at]
          end

          filtered_interactions << filtered_interaction
        end

        filtered_interactions
      end

      def self.all_slide_interactions
        lessons = lessons_map

        Participant.select(:id, :study_id).map do |participant|
          slide_view_events(lessons, participant.id).map do |lesson_event|
            e = lesson_event[1]
            lesson_id = lesson_event[0]
            slides = ContentModules::LessonModule.find(lesson_id).slides
            slide = find_slide_by_url(slides, e.current_url)

            {
              participant_id: participant.study_id,
              lesson_id: lesson_id,
              slide_id: slide.try(:id),
              slide_title: slide.try(:title),
              slide_selected_at: e.emitted_at.iso8601,
              slide_exited_at: next_event_at(e).try(:iso8601)
            }
          end
        end.flatten
      end

      # Events for a Participant in which a Lesson Slide is viewed.
      def self.slide_view_events(lessons, participant_id)
        EventCapture::Event
          .where(participant_id: participant_id, kind: %w( click render ))
          .select(:participant_id, :emitted_at, :payload)
          .order(:emitted_at)
          .to_a.map do |e|
            key = lessons.keys.find do |l|
              !e.current_url.match(/#{ l }(\/.*)?$/).nil?
            end

            key ? [lessons[key], e] : nil
          end.compact
      end

      # Return the time of the Event immediately following if one exists,
      # nil otherwise.
      def self.next_event_at(event)
        EventCapture::Event
          .where("participant_id = ? AND emitted_at > ?",
                 event.participant_id, event.emitted_at)
          .select(:participant_id, :emitted_at)
          .limit(1)
          .first.try(:emitted_at)
      end

      def self.find_slide_by_url(slides, url)
        slide_position = 1

        if url.match(/modules\/\d+$/).nil?
          slide_position = url[/\d+$/].to_i
        end

        slides.find_by_position(slide_position)
      end
    end
  end
end
