module ThinkFeelDoEngine
  # Used to change color of table row based on emotion
  module EmotionsHelper
    def emotion_class(emotional_rating)
      case emotional_rating.rating
      when 0..4
        "danger"
      when 6..10
        "success"
      else
        ""
      end
    end
  end
end
