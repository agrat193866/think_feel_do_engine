class AddFkConstraintsToMediaAccessEvents < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE media_access_events
            ADD CONSTRAINT fk_media_access_events_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE media_access_events
            DROP CONSTRAINT IF EXISTS fk_media_access_events_participants
        SQL
      end
    end
  end
end
