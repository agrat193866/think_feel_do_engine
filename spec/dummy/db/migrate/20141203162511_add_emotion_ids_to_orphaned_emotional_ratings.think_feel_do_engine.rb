# This migration comes from think_feel_do_engine (originally 20140722195542)
class AddEmotionIdsToOrphanedEmotionalRatings < ActiveRecord::Migration
  def change
    Participant.all.each do |participant|
      unless participant.emotions.empty?
        emotion_id = participant.emotions.first.id
        participant.emotional_ratings.each do |emotion_rating|
          emotion_rating.update!(emotion_id: emotion_id) unless emotion_rating.name
        end
      end
    end
  end
end
