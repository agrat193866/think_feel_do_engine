# This migration comes from think_feel_do_engine (originally 20140625140630)
class AddRecommendationsToThoughtPatterns < ActiveRecord::Migration
  def change
    add_column :thought_patterns, :recommendations, :text, default: "", null: false
  end
end