# This migration comes from bit_player (originally 20140305232705)
class CreateBitPlayerSlideshows < ActiveRecord::Migration
  def change
    create_table :bit_player_slideshows do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
