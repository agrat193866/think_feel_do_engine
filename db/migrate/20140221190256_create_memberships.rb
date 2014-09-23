class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :group, index: true, null: false
      t.references :participant, index: true, null: false

      t.timestamps
    end

    add_index :memberships, [:group_id, :participant_id], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE memberships
            ADD CONSTRAINT fk_memberships_groups
            FOREIGN KEY (group_id)
            REFERENCES groups(id)
        SQL
        execute <<-SQL
          ALTER TABLE memberships
            ADD CONSTRAINT fk_memberships_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE memberships
            DROP CONSTRAINT fk_memberships_groups
        SQL
        execute <<-SQL
          ALTER TABLE memberships
            DROP CONSTRAINT fk_memberships_participants
        SQL
      end
    end
  end
end
