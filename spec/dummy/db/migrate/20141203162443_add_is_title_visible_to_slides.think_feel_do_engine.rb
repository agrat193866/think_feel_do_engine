# This migration comes from think_feel_do_engine (originally 20140226174312)
class AddIsTitleVisibleToSlides < ActiveRecord::Migration
  def up
    add_column :slides, :is_title_visible, :boolean, null: false, default: true
  end

  def down
  end
end
