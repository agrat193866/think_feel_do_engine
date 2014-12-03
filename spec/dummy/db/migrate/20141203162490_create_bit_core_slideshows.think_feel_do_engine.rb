# This migration comes from think_feel_do_engine (originally 20140620171827)
# This migration comes from bit_core (originally 20140417173056)
class CreateBitCoreSlideshows < ActiveRecord::Migration
  def change
    create_table :bit_core_slideshows do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
