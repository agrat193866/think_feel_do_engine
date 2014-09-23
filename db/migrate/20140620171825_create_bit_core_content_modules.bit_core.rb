# This migration comes from bit_core (originally 20140415211458)
class CreateBitCoreContentModules < ActiveRecord::Migration
  def change
    create_table :bit_core_content_modules do |t|
      t.string :title, null: false
      t.integer :position, null: false, default: 1
      t.integer :bit_core_tool_id, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_core_content_modules
            ADD CONSTRAINT bit_core_content_module_position UNIQUE (bit_core_tool_id, position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_content_modules
            ADD CONSTRAINT fk_content_modules_tools
            FOREIGN KEY (bit_core_tool_id)
            REFERENCES bit_core_tools(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_core_content_modules
            DROP CONSTRAINT fk_content_modules_tools
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_content_modules
            DROP CONSTRAINT IF EXISTS bit_core_content_module_position
        SQL
      end
    end
  end
end
