class AddNullFalseToColumnsAndAssociateArmGroupJoinArmIdsToGroups < ActiveRecord::Migration
  def change
    arm_for_orphaned_groups = Arm.create!(title: "Arm for orphaned groups")
    Group.all.each do |group|
      unless group.arm_id
        group.arm_id = arm_for_orphaned_groups.id
        group.save!
      end
    end
    change_column_null :groups, :arm_id, false
  end
end
