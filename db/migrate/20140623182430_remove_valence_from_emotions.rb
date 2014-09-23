class RemoveValenceFromEmotions < ActiveRecord::Migration
  def change
    remove_column :emotions, :valence, :integer
  end
end
