# This migration comes from think_feel_do_engine (originally 20140721190945)
class NormalizeEmotions < ActiveRecord::Migration
  def change
    Participant.all.each do |participant|
      participant.emotions.each do |emotion|
        existing_emotion = participant.emotions.where(name: emotion.name.strip.downcase).first

        if existing_emotion && existing_emotion.id != emotion.id
          EmotionalRating.where(emotion_id: emotion.id).each do |e|
            e.update!(emotion_id: existing_emotion.id)
          end
          emotion.destroy!
        else
          emotion.save!
        end
      end
    end
  end
end
