# This migration comes from think_feel_do_engine (originally 20140331165739)
class AddEndDateToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :end_date, :date
  end
end
