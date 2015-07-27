# This migration comes from event_capture (originally 20150727151245)
class ChangeEventsEmittedAtToNull < ActiveRecord::Migration
  def change
    change_column_null :event_capture_events, :emitted_at, false
  end
end
