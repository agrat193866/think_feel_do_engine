class AddNullFalseToColumnsAndAssociateArmGroupJoinArmIdsToGroups < ActiveRecord::Migration
  def change
    change_column_null :groups, :arm_id, false
  end
end
