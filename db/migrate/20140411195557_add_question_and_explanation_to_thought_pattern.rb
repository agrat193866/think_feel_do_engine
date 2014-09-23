class AddQuestionAndExplanationToThoughtPattern < ActiveRecord::Migration
  def change
    add_column :thought_patterns, :explanation, :string
    add_column :thought_patterns, :question, :string
  end
end
