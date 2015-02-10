class AddSlideFkContstraintToMediaAccessEvents < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE media_access_events
            ADD CONSTRAINT fk_media_access_events_bit_core_slides
            FOREIGN KEY (bit_core_slide_id)
            REFERENCES bit_core_slides(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE media_access_events
            DROP CONSTRAINT IF EXISTS fk_media_access_events_bit_core_slides
        SQL
      end
    end
  end
end
