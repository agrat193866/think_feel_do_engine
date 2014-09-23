class AddTypeToSlides < ActiveRecord::Migration
  def up
    add_column :slides, :type, :string
    add_column :slides, :options, :text
  end

  def down
  end
end
