class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :participant, index: true, null: false
      t.references :activity_type, index: true, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :actual_accomplishment_intensity
      t.integer :actual_pleasure_intensity
      t.integer :predicted_accomplishment_intensity
      t.integer :predicted_pleasure_intensity
      t.boolean :is_complete, null: false, default: false
      t.text :noncompliance_reason

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE activities
            ADD CONSTRAINT fk_activities_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
        execute <<-SQL
          ALTER TABLE activities
            ADD CONSTRAINT fk_activities_types
            FOREIGN KEY (activity_type_id)
            REFERENCES activity_types(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE activities
            DROP CONSTRAINT fk_activities_participants
        SQL
        execute <<-SQL
          ALTER TABLE activities
            DROP CONSTRAINT fk_activities_types
        SQL
      end
    end
  end
end
