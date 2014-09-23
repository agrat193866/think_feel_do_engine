module ThinkFeelDoEngine
  module Coach
    # Provides helpers for transforming patient data for the viz
    module MoodsAndPhqVizHelper
      def emotional_ratings(participant)
        ratings = {}
        participant.emotional_ratings.order(:created_at).each do |rating|
          unless ratings[rating.name.to_sym]
            ratings[rating.name.to_sym] = []
          end
          ratings[rating.name.to_sym] << [rating.created_at.to_i, rating.rating]
        end
        ratings.keys.map { |key| [key.to_sym, ratings[key.to_sym]] }
      end

      def mood_ratings(participant)
        participant.moods.order(:created_at).map do |mood|
          [mood.created_at.to_i, mood.rating]
        end
      end
    end
  end
end
