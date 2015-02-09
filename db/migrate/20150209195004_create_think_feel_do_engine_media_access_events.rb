class CreateThinkFeelDoEngineMediaAccessEvents < ActiveRecord::Migration
  def change
    create_table :media_access_events do |t|
      t.string :media_type
      t.references :participant, index: true
      t.string :media_link
      t.datetime :end_time

      t.timestamps
    end
  end
end
