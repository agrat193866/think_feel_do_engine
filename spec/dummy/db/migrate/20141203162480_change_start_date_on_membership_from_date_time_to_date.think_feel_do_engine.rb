# This migration comes from think_feel_do_engine (originally 20140421192355)
class ChangeStartDateOnMembershipFromDateTimeToDate < ActiveRecord::Migration
  def up
    change_column :memberships, :start_date, :date
  end

  def down
    change_column :memberships, :start_date, :datetime
  end
end
