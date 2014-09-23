class AddSignedOutAtToParticipantLoginEvents < ActiveRecord::Migration
  def change
    add_column :participant_login_events, :signed_out_at, :datetime
  end
end
