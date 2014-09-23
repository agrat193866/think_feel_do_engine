# This migration comes from bit_core (originally 20140625133118)
class AddTypeToContentModules < ActiveRecord::Migration
  def change
    add_column :bit_core_content_modules, :type, :string
  end
end
