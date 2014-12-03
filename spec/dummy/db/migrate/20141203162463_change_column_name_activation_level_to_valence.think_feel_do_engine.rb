# This migration comes from think_feel_do_engine (originally 20140314203044)
class ChangeColumnNameActivationLevelToValence < ActiveRecord::Migration
  def change
    remove_index :emotions, column: :activation_level
    remove_index :emotions, column: :intensity
    remove_index :emotions, column: :name
    rename_column :emotions, :activation_level, :valence
  end
end
