# This migration comes from think_feel_do_engine (originally 20141201165610)
class ChangeColumnBitCoreToolsArmIdToNull < ActiveRecord::Migration
  def change
    change_column_null :bit_core_tools, :arm_id, false
  end
end
