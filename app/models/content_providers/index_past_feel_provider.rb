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
          emotional_ratings: emotional_rating_daily_averages(participant),
          mood_ratings: mood_rating_daily_averages(participant)
        }
      )
    end

    def show_nav_link?
      true
    end

    def average_rating(array)
      array.reduce(:+)/ array.size
    end

    def emotional_rating_daily_averages(participant)
      averaged_ratings = []

      daily_ratings = participant.emotional_ratings.group_by { |er| er.created_at.to_date }

      daily_ratings.each do |day, emotions_array|
        positive_ratings = emotions_array.collect{|emotion| emotion.rating if emotion.is_positive}.compact
        if positive_ratings.size > 0
          daily_positive = {day: day, intensity: average_rating(positive_ratings), is_positive: true}
          averaged_ratings << daily_positive
        end
        negative_ratings = emotions_array.collect{|emotion| emotion.rating unless emotion.is_positive}.compact
        if negative_ratings.size > 0
          daily_negative = {day: day, intensity: average_rating(negative_ratings), is_positive: false}
          averaged_ratings << daily_negative
        end
      end

      averaged_ratings
    end

    def mood_rating_daily_averages(participant)
      averaged_ratings = []
      daily_ratings = participant.moods.group_by { |mood| mood.created_at.to_date }
      daily_ratings.each do |day, moods_array|
        ratings = moods_array.collect{|mood| mood.rating}.compact
        if ratings.size > 0
          averaged_ratings << {day: day, intensity: average_rating(ratings)}
        end
      end
      averaged_ratings
    end
  end
end
