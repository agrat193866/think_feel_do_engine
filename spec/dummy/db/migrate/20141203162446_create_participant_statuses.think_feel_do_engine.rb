# This migration comes from think_feel_do_engine (originally 20140304020641)
class CreateParticipantStatuses < ActiveRecord::Migration
  def up
    create_table :participant_statuses do |t|
      t.string :context
      t.integer :module_position
      t.integer :provider_position
      t.integer :content_position
      t.references :participant, index: true

      t.timestamps
    end
  end

  def down
  end
end
