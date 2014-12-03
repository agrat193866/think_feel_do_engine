# This migration comes from think_feel_do_engine (originally 20140821184357)
class AddIsScheduledToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_scheduled, :boolean, null: false, default: false
  end
end
