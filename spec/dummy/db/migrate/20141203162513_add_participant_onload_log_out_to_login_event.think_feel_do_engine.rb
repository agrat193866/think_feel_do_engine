# This migration comes from think_feel_do_engine (originally 20140725185012)
class AddParticipantOnloadLogOutToLoginEvent < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :onload_at, :datetime
  end
end
