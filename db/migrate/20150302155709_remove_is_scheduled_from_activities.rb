class RemoveIsScheduledFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :is_scheduled, :boolean, default: false, null: false
  end
end
