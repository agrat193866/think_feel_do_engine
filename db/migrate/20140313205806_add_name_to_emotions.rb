class AddNameToEmotions < ActiveRecord::Migration
  def change
    add_column :emotions, :name, :string
    add_index :emotions, :name
  end
end
