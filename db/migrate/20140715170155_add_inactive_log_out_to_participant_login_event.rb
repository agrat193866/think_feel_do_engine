class AddInactiveLogOutToParticipantLoginEvent < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :inactive_log_out, :boolean, default: false
  end
end
