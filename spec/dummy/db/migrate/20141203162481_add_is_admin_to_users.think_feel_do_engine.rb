# This migration comes from think_feel_do_engine (originally 20140501170217)
class AddIsAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, default: false, null: false
  end
end