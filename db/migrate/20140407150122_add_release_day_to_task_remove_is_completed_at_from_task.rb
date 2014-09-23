class AddReleaseDayToTaskRemoveIsCompletedAtFromTask < ActiveRecord::Migration
  def change
    add_column :tasks, :release_day, :integer
    remove_column :tasks, :is_complete, :boolean
  end
end
