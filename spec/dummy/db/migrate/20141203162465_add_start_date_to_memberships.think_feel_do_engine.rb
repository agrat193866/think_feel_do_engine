# This migration comes from think_feel_do_engine (originally 20140320183600)
class AddStartDateToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :start_date, :datetime
  end
end