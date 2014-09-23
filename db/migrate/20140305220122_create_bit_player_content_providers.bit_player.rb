# This migration comes from bit_player (originally 20140305201300)
class CreateBitPlayerContentProviders < ActiveRecord::Migration
  def change
    create_table :bit_player_content_providers do |t|
      t.string :type, null: false
      t.string :source_content_type
      t.integer :source_content_id
      t.references :bit_player_content_module, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end

    add_index :bit_player_content_providers, :bit_player_content_module_id, name: 'content_module_index'

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_player_content_providers
            ADD CONSTRAINT fk_content_providers_modules
            FOREIGN KEY (bit_player_content_module_id)
            REFERENCES bit_player_content_modules(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_player_content_providers
            DROP CONSTRAINT fk_content_providers_modules
        SQL
      end
    end
  end
end
