class RequireTitlesOnSlides < ActiveRecord::Migration
  def up
    change_column_null :slides, :title, false
  end

  def down
  end
end
