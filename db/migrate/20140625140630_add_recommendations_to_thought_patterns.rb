class AddRecommendationsToThoughtPatterns < ActiveRecord::Migration
  def change
    add_column :thought_patterns, :recommendations, :text, default: "", null: false
  end
end