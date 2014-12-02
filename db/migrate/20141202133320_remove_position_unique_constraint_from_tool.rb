class RemovePositionUniqueConstraintFromTool < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_core_tools
            DROP CONSTRAINT IF EXISTS bit_core_tool_position
        SQL
      end

      dir.down do
        # make deferrable so that positions can be updated
        execute <<-SQL
          ALTER TABLE bit_core_tools
            ADD CONSTRAINT bit_core_tool_position UNIQUE (position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL
      end
    end
  end
end
