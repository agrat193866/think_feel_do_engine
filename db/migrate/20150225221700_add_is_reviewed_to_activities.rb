class AddIsReviewedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_reviewed, :boolean, default: false, null: false
  end
end
