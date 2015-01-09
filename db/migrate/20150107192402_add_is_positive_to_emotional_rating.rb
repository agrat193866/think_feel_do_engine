class AddIsPositiveToEmotionalRating < ActiveRecord::Migration
  def change
    add_column :emotional_ratings, :is_positive, :boolean
  end
end
