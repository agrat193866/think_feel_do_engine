class AddIsPositiveToEmotion < ActiveRecord::Migration
  def change
    add_column :emotions, :is_positive, :boolean, default: true, null: false
  end
end

