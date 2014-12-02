class ChangeColumnBitCoreToolsArmIdToNull < ActiveRecord::Migration
  def change
    change_column_null :bit_core_tools, :arm_id, false
  end
end
