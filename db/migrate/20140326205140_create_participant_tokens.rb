class CreateParticipantTokens < ActiveRecord::Migration
  def change
    create_table :participant_tokens do |t|
      t.references :participant, index: true, null: false
      t.date :release_date
      t.string :token_type, null: false
      t.string :token, null: false

      t.timestamps
    end

    add_index :participant_tokens, [:participant_id, :token], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE participant_tokens
            ADD CONSTRAINT fk_tokens_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE participant_tokens
            DROP CONSTRAINT fk_tokens_participants
        SQL
      end
    end
  end
end
