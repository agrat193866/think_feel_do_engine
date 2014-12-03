# This migration comes from think_feel_do_engine (originally 20140318163703)
class CreateGroupSlideshowJoins < ActiveRecord::Migration
  def change
    create_table :group_slideshow_joins do |t|
      t.integer :release_day, null: false, default: 1
      t.integer :creator_id, null: false
      t.integer :group_id, null: false
      t.integer :bit_player_slideshow_id, null: false

      t.timestamps
    end
  end
end
