# This migration comes from think_feel_do_engine (originally 20141121201238)
class AddArmIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :arm_id, :integer
  end
end
