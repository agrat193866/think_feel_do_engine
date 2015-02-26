class RemoveIsMonitoredFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :is_monitored, :boolean, default: false, null: false
  end
end
