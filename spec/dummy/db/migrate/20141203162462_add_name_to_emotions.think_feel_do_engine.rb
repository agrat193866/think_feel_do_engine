# This migration comes from think_feel_do_engine (originally 20140313205806)
class AddNameToEmotions < ActiveRecord::Migration
  def change
    add_column :emotions, :name, :string
    add_index :emotions, :name
  end
end
