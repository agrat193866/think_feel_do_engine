# This migration comes from think_feel_do_engine (originally 20141027181539)
class AddContactStatusToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :contact_status, :string
  end
end
