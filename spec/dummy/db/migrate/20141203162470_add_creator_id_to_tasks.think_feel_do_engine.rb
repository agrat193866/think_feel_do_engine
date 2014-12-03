# This migration comes from think_feel_do_engine (originally 20140402170153)
class AddCreatorIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :creator_id, :integer
  end
end
