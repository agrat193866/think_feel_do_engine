# This migration comes from think_feel_do_engine (originally 20140818202120)
class AddHasDidacticContentToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :has_didactic_content, :boolean, null: false, default: true
  end
end
