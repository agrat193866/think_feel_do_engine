class AddContactStatusToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :contact_status, :string
  end
end
