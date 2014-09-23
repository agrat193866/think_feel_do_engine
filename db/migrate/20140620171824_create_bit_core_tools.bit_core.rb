# This migration comes from bit_core (originally 20140415210052)
class CreateBitCoreTools < ActiveRecord::Migration
  def change
    create_table :bit_core_tools do |t|
      t.string :title, null: false, unique: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        # make deferrable so that positions can be updated
        execute <<-SQL
          ALTER TABLE bit_core_tools
            ADD CONSTRAINT bit_core_tool_position UNIQUE (position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_core_tools
            DROP CONSTRAINT IF EXISTS bit_core_tool_position
        SQL
      end
    end
  end
end
