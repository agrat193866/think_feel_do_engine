class AddChallengingThoughtAndAsIfToThought < ActiveRecord::Migration
  def change
    add_column :thoughts, :challenging_thought, :text
    add_column :thoughts, :act_as_if, :text
  end
end
