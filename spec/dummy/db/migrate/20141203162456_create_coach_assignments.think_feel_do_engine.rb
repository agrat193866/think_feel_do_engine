# This migration comes from think_feel_do_engine (originally 20140306175954)
class CreateCoachAssignments < ActiveRecord::Migration
  def change
    create_table :coach_assignments do |t|
      t.references :participant, index: true, null: false
      t.integer :coach_id, null: false

      t.timestamps
    end

    add_index :coach_assignments, :coach_id
  end
end
