# This migration comes from think_feel_do_engine (originally 20140725164219)
class AddIsMonitoredToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :is_monitored, :boolean, default: false, null: false
  end
end