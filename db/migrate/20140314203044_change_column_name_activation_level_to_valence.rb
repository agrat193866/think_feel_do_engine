class ChangeColumnNameActivationLevelToValence < ActiveRecord::Migration
  def change
    remove_index :emotions, column: :activation_level
    remove_index :emotions, column: :intensity
    remove_index :emotions, column: :name
    rename_column :emotions, :activation_level, :valence
  end
end
