class AddSteppedOnColumnToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :stepped_on, :date

    Participant.each do |participant|
      if participant.is_stepped
        participant.stepped_on = Date.today
        participant.save
      end
    end

  end
end
