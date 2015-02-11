# This migration comes from bit_core (originally 20150210161229)
class AddToolConstraint < ActiveRecord::Migration
  def change
    BitCore::Tool.all.each do |t|
      t.destroy! if t.arm.nil?
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_core_tools
            ADD CONSTRAINT fk_tools_arms
            FOREIGN KEY (arm_id)
            REFERENCES arms(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_core_tools
            DROP CONSTRAINT IF EXISTS fk_tools_arms
        SQL
      end
    end
  end
end
