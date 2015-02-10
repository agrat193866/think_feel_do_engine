class AddSteppedOnColumnToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :stepped_on, :date

    Membership.where("memberships.is_stepped = ?", true) do |membership|
      membership.stepped_on = Date.today
      membership.save
    end
  end
end
