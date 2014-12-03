# This migration comes from think_feel_do_engine (originally 20140703203931)
class AddTerminationDayToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :termination_day, :integer
  end
end
