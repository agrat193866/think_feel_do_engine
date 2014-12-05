class AddArmIdToBitCoreTools < ActiveRecord::Migration
  def up
    add_column :bit_core_tools, :arm_id, :integer

    arm = Arm.create!(title: "Arm for Orphaned Modules")

    BitCore::Tool.all.each do |tool|
      if Arm.count == 0
        tool.arm_id = arm.id
      else
        tool.arm_id = Arm.first.id
      end
      tool.save!
    end
  end

  def down
    remove_column :bit_core_tools, :arm_id, :integer

    a = Arm.find_by_title("Arm for Orphaned Modules")
    a.destroy if a
  end
end
