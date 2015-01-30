class AddDescriptionToTools < ActiveRecord::Migration
  def change
    add_column :bit_core_tools, :description, :string, limit: 2048
  end
end
