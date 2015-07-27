# This migration comes from event_capture (originally 20150727145934)
class ChangeEventsRecordedAtToNull < ActiveRecord::Migration
  def change
    change_column_null :event_capture_events, :recorded_at, false
  end
end
