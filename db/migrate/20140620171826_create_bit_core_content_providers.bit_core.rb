# This migration comes from bit_core (originally 20140415213346)
class CreateBitCoreContentProviders < ActiveRecord::Migration
  def change
    create_table :bit_core_content_providers do |t|
      t.string :type, null: false
      t.string :source_content_type
      t.integer :source_content_id
      t.integer :bit_core_content_module_id, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_core_content_providers
            ADD CONSTRAINT bit_core_content_provider_position UNIQUE (bit_core_content_module_id, position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_content_providers
            ADD CONSTRAINT fk_content_providers_modules
            FOREIGN KEY (bit_core_content_module_id)
            REFERENCES bit_core_content_modules(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_core_content_providers
            DROP CONSTRAINT fk_content_providers_modules
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_content_providers
            DROP CONSTRAINT IF EXISTS bit_core_content_provider_position
        SQL
      end
    end
  end
end
