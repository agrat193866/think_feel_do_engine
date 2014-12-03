# This migration comes from think_feel_do_engine (originally 20140715170155)
class AddInactiveLogOutToParticipantLoginEvent < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :inactive_log_out, :boolean, default: false
  end
end
