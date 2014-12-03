# This migration comes from think_feel_do_engine (originally 20140501190812)
class AddParticipantLoginEvent < ActiveRecord::Migration
  def change
    create_table :participant_login_events do |t|
      t.references :participant, index: true

      t.timestamps
    end
  end
end
