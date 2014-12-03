# This migration comes from think_feel_do_engine (originally 20140407150122)
class AddReleaseDayToTaskRemoveIsCompletedAtFromTask < ActiveRecord::Migration
  def change
    add_column :tasks, :release_day, :integer
    remove_column :tasks, :is_complete, :boolean
  end
end
