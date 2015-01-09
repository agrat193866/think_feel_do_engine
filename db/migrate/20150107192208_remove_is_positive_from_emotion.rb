class RemoveIsPositiveFromEmotion < ActiveRecord::Migration
  def change
    remove_column :emotions, :is_positive
  end
end
