# This migration comes from think_feel_do_engine (originally 20140702192100)
class CreateContentProviderPolicies < ActiveRecord::Migration
  def change
    create_table :content_provider_policies do |t|
      t.boolean :is_skippable_after_first_viewing, null: false, default: false
      t.integer :bit_core_content_provider_id, null: false

      t.timestamps
    end
  end
end
