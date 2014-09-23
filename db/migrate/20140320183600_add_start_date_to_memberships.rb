class AddStartDateToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :start_date, :datetime
  end
end