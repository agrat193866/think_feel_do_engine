# This migration comes from bit_core (originally 20150130155627)
class AddTypeToTools < ActiveRecord::Migration
  def change
    add_column :bit_core_tools, :type, :string
  end
end
