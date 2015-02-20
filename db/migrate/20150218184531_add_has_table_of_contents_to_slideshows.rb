class AddHasTableOfContentsToSlideshows < ActiveRecord::Migration
  def change
    add_column :bit_core_slideshows,
               :has_table_of_contents,
               :boolean,
               null: false,
               default: false
  end
end
