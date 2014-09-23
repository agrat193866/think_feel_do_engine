class AddIsMonitoredToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :is_monitored, :boolean, default: false, null: false
  end
end