class AddParticipantOnloadLogOutToLoginEvent < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :onload_at, :datetime
  end
end
