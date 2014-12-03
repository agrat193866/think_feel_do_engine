# This migration comes from think_feel_do_engine (originally 20140415165729)
class AddStartDayToTaskStatuses < ActiveRecord::Migration
  def change
    add_column :task_statuses, :start_day, :integer, null: :false
  end
end
