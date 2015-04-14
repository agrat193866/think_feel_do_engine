class AddArmIdToBitCoreTools < ActiveRecord::Migration
  def up
    add_column :bit_core_tools, :arm_id, :integer
  end

  def down
    remove_column :bit_core_tools, :arm_id, :integer
  end
end
