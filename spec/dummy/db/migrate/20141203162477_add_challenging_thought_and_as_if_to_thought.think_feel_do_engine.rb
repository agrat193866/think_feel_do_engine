# This migration comes from think_feel_do_engine (originally 20140411195804)
class AddChallengingThoughtAndAsIfToThought < ActiveRecord::Migration
  def change
    add_column :thoughts, :challenging_thought, :text
    add_column :thoughts, :act_as_if, :text
  end
end
