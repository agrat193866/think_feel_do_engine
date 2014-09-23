class AddTerminationDayToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :termination_day, :integer
  end
end
