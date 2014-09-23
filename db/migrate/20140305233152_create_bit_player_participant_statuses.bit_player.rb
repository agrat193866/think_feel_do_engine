# This migration comes from bit_player (originally 20140305232705)
class CreateBitPlayerParticipantStatuses < ActiveRecord::Migration
  def change
    create_table :bit_player_participant_statuses do |t|
      t.string :context
      t.integer :module_position
      t.integer :provider_position
      t.integer :content_position
      t.integer :participant_id, null: false

      t.timestamps
    end

    add_index :bit_player_participant_statuses, :participant_id, name: :index_participant_statuses_on_participant_id
  end
end
