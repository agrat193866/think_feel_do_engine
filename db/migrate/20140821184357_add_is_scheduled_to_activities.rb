class AddIsScheduledToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_scheduled, :boolean, null: false, default: false
  end
end
