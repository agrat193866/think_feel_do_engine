# This migration comes from think_feel_do_engine (originally 20140710122908)
class CreateSlideshowAnchors < ActiveRecord::Migration
  def change
    create_table :slideshow_anchors do |t|
      t.integer :bit_core_slideshow_id
      t.string :target_name

      t.timestamps
    end
  end
end
