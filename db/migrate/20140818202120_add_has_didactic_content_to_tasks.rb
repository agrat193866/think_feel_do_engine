class AddHasDidacticContentToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :has_didactic_content, :boolean, null: false, default: true
  end
end
