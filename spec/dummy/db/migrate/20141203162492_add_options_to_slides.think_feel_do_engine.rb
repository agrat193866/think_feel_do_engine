# This migration comes from think_feel_do_engine (originally 20140620181933)
# This migration comes from bit_core (originally 20140620174146)
class AddOptionsToSlides < ActiveRecord::Migration
  def change
    add_column :bit_core_slides, :options, :text
  end
end
