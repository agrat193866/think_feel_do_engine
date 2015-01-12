module ContentProviders
  # Displays all feelings the participant has had in the past
  class IndexPastFeelProvider < BitCore::ContentProvider
    def data_class_name
      "Emotion"
    end

    def render_current(options)
      participant = options.view_context.current_participant

      options.view_context.render(
        template: "think_feel_do_engine/emotions/index",
        locals: {
          emotional_ratings: emotional_ratings(participant).to_json,
          mood_ratings: mood_ratings(participant)
        }
      )
    end

    def show_nav_link?
      true
    end

    def emotional_ratings(participant)
      participant.emotional_ratings.collect do |er|
        {day: er.created_at.to_s, intensity: er.rating, is_positive: er.is_positive}
      end
    end

    def mood_ratings(participant)
      participant.moods.order(:created_at).map do |mood|
        [mood.created_at.to_i, mood.rating]
      end
    end
  end
end
