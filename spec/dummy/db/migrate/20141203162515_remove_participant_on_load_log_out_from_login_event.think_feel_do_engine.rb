# This migration comes from think_feel_do_engine (originally 20140729171907)
class RemoveParticipantOnLoadLogOutFromLoginEvent < ActiveRecord::Migration
  def change
    remove_column :participant_login_events, :onload_at, :datetime
  end
end
