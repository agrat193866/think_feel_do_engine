# This migration comes from think_feel_do_engine (originally 20140228042747)
class AddTypeToSlides < ActiveRecord::Migration
  def up
    add_column :slides, :type, :string
    add_column :slides, :options, :text
  end

  def down
  end
end
