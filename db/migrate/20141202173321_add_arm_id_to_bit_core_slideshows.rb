class AddArmIdToBitCoreSlideshows < ActiveRecord::Migration
  def change
    add_column :bit_core_slideshows, :arm_id, :integer
  end
end
