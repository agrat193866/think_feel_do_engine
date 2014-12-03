# This migration comes from think_feel_do_engine (originally 20140729151610)
class AddSignedOutAtToParticipantLoginEvents < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :signed_out_at, :datetime
  end
end
