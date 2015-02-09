class CreateWaiAssessments < ActiveRecord::Migration
  def change
    create_table :wai_assessments do |t|
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
      t.integer :q10
      t.integer :q11
      t.integer :q12
      t.integer :participant_id, null: false
      t.integer :q1_editor_id
      t.integer :q2_editor_id
      t.integer :q3_editor_id
      t.integer :q4_editor_id
      t.integer :q5_editor_id
      t.integer :q6_editor_id
      t.integer :q7_editor_id
      t.integer :q8_editor_id
      t.integer :q9_editor_id
      t.integer :q10_editor_id
      t.integer :q11_editor_id
      t.integer :q12_editor_id

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE wai_assessments
            ADD CONSTRAINT fk_wai_assessments_participants
            FOREIGN KEY (participant_id)
            REFERENCES participants(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE wai_assessments
            DROP CONSTRAINT IF EXISTS fk_wai_assessments_participants
        SQL
      end
    end
  end
end
