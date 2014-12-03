# This migration comes from think_feel_do_engine (originally 20140411195557)
class AddQuestionAndExplanationToThoughtPattern < ActiveRecord::Migration
  def change
    add_column :thought_patterns, :explanation, :string
    add_column :thought_patterns, :question, :string
  end
end
