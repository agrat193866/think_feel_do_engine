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
          emotional_ratings: participant.emotional_rating_daily_averages,
          mood_ratings: participant.mood_rating_daily_averages
        }
      )
    end

    def show_nav_link?
      true
    end
  end
end
