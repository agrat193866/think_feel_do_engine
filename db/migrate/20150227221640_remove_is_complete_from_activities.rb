class RemoveIsCompleteFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :is_complete, :boolean, default: false, null: false
  end
end
