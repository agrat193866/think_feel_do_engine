class CreateThoughts < ActiveRecord::Migration
  def change
    create_table :thoughts do |t|
      t.text :content, null: false
      t.string :effect, null: false
      t.references :participant, index: true, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE thoughts
            ADD CONSTRAINT fk_thoughts_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL

        execute <<-SQL
          ALTER TABLE thoughts
            ADD CONSTRAINT effect_valid
            CHECK (effect = ANY ('{"helpful", "harmful", "neither"}'))
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE thoughts
            DROP CONSTRAINT fk_thoughts_participants
        SQL

        execute <<-SQL
          ALTER TABLE thoughts
            DROP CONSTRAINT effect_valid
        SQL
      end
    end
  end
end
