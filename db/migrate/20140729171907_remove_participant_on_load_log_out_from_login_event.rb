class RemoveParticipantOnLoadLogOutFromLoginEvent < ActiveRecord::Migration
  def change
    remove_column :participant_login_events, :onload_at, :datetime
  end
end
