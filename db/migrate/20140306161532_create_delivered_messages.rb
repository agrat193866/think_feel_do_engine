class CreateDeliveredMessages < ActiveRecord::Migration
  def change
    create_table :delivered_messages do |t|
      t.references :message, index: true, null: false
      t.references :recipient, polymorphic: true, index: true, null: false
      t.boolean :is_read, default: false, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE delivered_messages
            ADD CONSTRAINT fk_delivered_message_message
            FOREIGN KEY (message_id)
            REFERENCES messages(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE delivered_messages
            DROP CONSTRAINT fk_delivered_message_message
        SQL
      end
    end
  end
end
