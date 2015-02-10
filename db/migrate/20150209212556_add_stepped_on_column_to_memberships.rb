class AddSteppedOnColumnToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :stepped_on, :date

    Participant.where("memberships.is_stepped = ?", true) do |participant|
      participant.stepped_on = Date.today
      participant.save
    end
  end
end
