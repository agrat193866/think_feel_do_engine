# This migration comes from think_feel_do_engine (originally 20140623182430)
class RemoveValenceFromEmotions < ActiveRecord::Migration
  def change
    remove_column :emotions, :valence, :integer
  end
end
