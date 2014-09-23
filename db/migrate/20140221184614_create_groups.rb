class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title, null: false
      t.integer :creator_id, null: false

      t.timestamps
    end

    add_index :groups, :title, unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE groups
            ADD CONSTRAINT fk_groups_users
            FOREIGN KEY (creator_id)
            REFERENCES users(id)
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE groups
            DROP CONSTRAINT fk_groups_users
        SQL
      end
    end
  end
end
