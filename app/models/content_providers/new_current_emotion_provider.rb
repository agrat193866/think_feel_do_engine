module ContentProviders
  # Participant rates their current mood
  class NewCurrentEmotionProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/emotions/new_current",
        locals: {
          emotional_rating: options
            .view_context
            .current_participant
            .emotional_ratings
            .build,
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "EmotionalRating"
    end

    def data_attributes
      [:emotion_id, :name, :participant_id, :rating, :is_positive]
    end

    def show_nav_link?
      false
    end
  end
end
