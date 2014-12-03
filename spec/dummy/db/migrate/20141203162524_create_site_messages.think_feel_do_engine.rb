# This migration comes from think_feel_do_engine (originally 20141110190545)
class CreateSiteMessages < ActiveRecord::Migration
  def change
    create_table :site_messages do |t|
      t.references :participant, index: true, null: false
      t.string :subject, null: false
      t.text :body, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE site_messages
            ADD CONSTRAINT fk_site_messages_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE site_messages
            DROP CONSTRAINT fk_site_messages_participants
        SQL
      end
    end
  end
end
