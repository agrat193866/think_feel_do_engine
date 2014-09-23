class AddIsTitleVisibleToSlides < ActiveRecord::Migration
  def up
    add_column :slides, :is_title_visible, :boolean, null: false, default: true
  end

  def down
  end
end
