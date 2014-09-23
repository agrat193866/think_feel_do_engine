class AddEndDateToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :end_date, :date
  end
end
