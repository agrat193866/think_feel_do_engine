# This migration comes from bit_player (originally 20140402224913)
class CreateBitPlayerTools < ActiveRecord::Migration
  def change
    create_table :bit_player_tools do |t|
      t.string :title, null: false
      t.integer :position
      t.boolean :is_home, default: false, null: false

      t.timestamps
    end
    add_index :bit_player_tools, :title, unique: true
    add_index :bit_player_tools, :position, unique: true
  end
end
