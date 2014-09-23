class CreateActivityTypes < ActiveRecord::Migration
  def change
    create_table :activity_types do |t|
      t.references :participant, index: true
      t.string :title, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE activity_types
            ADD CONSTRAINT fk_activity_types_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE activity_types
            DROP CONSTRAINT fk_activity_types_participants
        SQL
      end
    end
  end
end
