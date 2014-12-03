# This migration comes from think_feel_do_engine (originally 20141202173321)
class AddArmIdToBitCoreSlideshows < ActiveRecord::Migration
  def change
    add_column :bit_core_slideshows, :arm_id, :integer
  end
end
