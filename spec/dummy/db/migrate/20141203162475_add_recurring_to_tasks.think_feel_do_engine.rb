# This migration comes from think_feel_do_engine (originally 20140411184738)
class AddRecurringToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :is_recurring, :boolean, default: false, null: false
  end
end