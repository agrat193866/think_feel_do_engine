class RemoveRatingFromEmotionRemoveIntensityFromEmotion < ActiveRecord::Migration
  def change
    remove_column :emotions, :rating, :integer
    remove_column :emotions, :intensity, :integer
  end
end
