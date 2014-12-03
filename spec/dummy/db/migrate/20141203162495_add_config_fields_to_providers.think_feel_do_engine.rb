# This migration comes from think_feel_do_engine (originally 20140621024854)
# This migration comes from bit_core (originally 20140620174147)
class AddConfigFieldsToProviders < ActiveRecord::Migration
  def change
    add_column :bit_core_content_providers, :template_path, :string
    add_column :bit_core_content_providers, :data_class_name, :string
    add_column :bit_core_content_providers, :data_attributes, :text
    add_column :bit_core_content_providers, :show_next_nav, :boolean
    add_column :bit_core_content_providers, :locals, :text
  end
end
