class CreateEngagements < ActiveRecord::Migration
  def change
    create_table :engagements do |t|
      t.integer :task_status_id
      t.datetime :completed_at

      t.timestamps
    end
  end
end
