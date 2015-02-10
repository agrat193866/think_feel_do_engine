class AddSlideReferenceToMediaAccessEvents < ActiveRecord::Migration
  def change
    change_column_null :media_access_events, :participant_id, false
    change_column_null :media_access_events, :media_type, false
    change_column_null :media_access_events, :media_link, false
    add_reference :media_access_events, :bit_core_slide, null: false
  end
end
