class CreatePhqAssessments < ActiveRecord::Migration
  def change
    create_table :phq_assessments do |t|
      t.date :release_date, null: false
      t.integer :q1
      t.integer :q2
      t.integer :q3
      t.integer :q4
      t.integer :q5
      t.integer :q6
      t.integer :q7
      t.integer :q8
      t.integer :q9
      t.references :participant, index: true, null: false

      t.timestamps
    end

    add_index :phq_assessments, [:participant_id, :release_date], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE phq_assessments
            ADD CONSTRAINT fk_phq_assessments_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE phq_assessments
            DROP CONSTRAINT fk_phq_assessments_participants
        SQL
      end
    end
  end
end
