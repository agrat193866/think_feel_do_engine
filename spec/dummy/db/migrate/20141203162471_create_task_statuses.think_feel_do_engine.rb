# This migration comes from think_feel_do_engine (originally 20140407134214)
class CreateTaskStatuses < ActiveRecord::Migration
  def change
    create_table :task_statuses do |t|
      t.integer :membership_id
      t.integer :task_id
      t.datetime :completed_at

      t.timestamps
    end
  end
end
