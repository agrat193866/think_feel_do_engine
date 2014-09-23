class CreateContentProviders < ActiveRecord::Migration
  def up
    create_table :content_providers do |t|
      t.string :type, null: false
      t.string :source_content_type
      t.integer :source_content_id
      t.references :content_module, index: true, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE content_providers
            ADD CONSTRAINT fk_content_providers_modules
            FOREIGN KEY (content_module_id)
            REFERENCES content_modules(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE content_providers
            DROP CONSTRAINT fk_content_providers_modules
        SQL
      end
    end
  end

  def down
  end
end
