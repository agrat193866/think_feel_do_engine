class CreateAwakePeriods < ActiveRecord::Migration
  def change
    create_table :awake_periods do |t|
      t.references :participant, index: true, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE awake_periods
            ADD CONSTRAINT fk_awake_periods_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE awake_periods
            DROP CONSTRAINT fk_awake_periods_participants
        SQL
      end
    end
  end
end
