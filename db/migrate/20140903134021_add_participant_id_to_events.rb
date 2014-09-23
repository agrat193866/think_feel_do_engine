class AddParticipantIdToEvents < ActiveRecord::Migration
  def change
    add_column :event_capture_events, :participant_id, :integer, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE event_capture_events
            ADD CONSTRAINT fk_events_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE event_capture_events
            DROP CONSTRAINT IF EXISTS fk_events_participants
        SQL
      end
    end
  end
end
