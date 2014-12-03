# This migration comes from think_feel_do_engine (originally 20140624165626)
class RemoveRatingFromEmotionRemoveIntensityFromEmotion < ActiveRecord::Migration
  def change
    remove_column :emotions, :rating, :integer
    remove_column :emotions, :intensity, :integer
  end
end
