# This migration comes from think_feel_do_engine (originally 20140624165438)
class CreateEmotionalRatings < ActiveRecord::Migration
  def change
    create_table :emotional_ratings do |t|
      t.integer :participant_id
      t.integer :emotion_id
      t.integer :rating
      t.timestamps
    end
  end
end
