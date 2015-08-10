class NullifyEmptyThoughtsColumns < ActiveRecord::Migration
  def up
    Thought.all.each do |thought|
      # force before_validation callback to run
      thought.valid?
      thought.update_columns(
        challenging_thought: thought.challenging_thought,
        act_as_if: thought.act_as_if
      )
    end
  end

  def down
  end
end
