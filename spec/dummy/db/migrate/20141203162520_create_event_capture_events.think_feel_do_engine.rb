# This migration comes from think_feel_do_engine (originally 20140902204337)
# This migration comes from event_capture (originally 20140829235335)
class CreateEventCaptureEvents < ActiveRecord::Migration
  def change
    create_table :event_capture_events do |t|
      t.datetime :emitted_at
      t.datetime :recorded_at
      t.text :payload
      t.string :user_id
      t.string :user_agent
      t.string :source
      t.string :kind
    end
  end
end
