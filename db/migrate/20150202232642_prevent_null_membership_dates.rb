class PreventNullMembershipDates < ActiveRecord::Migration
  def change
    change_column_null :memberships, :start_date, false
    change_column_null :memberships, :end_date, false
  end
end
