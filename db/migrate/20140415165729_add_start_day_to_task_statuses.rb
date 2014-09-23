class AddStartDayToTaskStatuses < ActiveRecord::Migration
  def change
    add_column :task_statuses, :start_day, :integer, null: :false
  end
end
