# This migration comes from think_feel_do_engine (originally 20140224194936)
class RequireTitlesOnSlides < ActiveRecord::Migration
  def up
    change_column_null :slides, :title, false
  end

  def down
  end
end
