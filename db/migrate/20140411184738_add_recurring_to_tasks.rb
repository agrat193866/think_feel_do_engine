class AddRecurringToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :is_recurring, :boolean, default: false, null: false
  end
end