class RenameColumnParticipantIdOnEmotionsToCreatorId < ActiveRecord::Migration
  def change
    rename_column :emotions, :participant_id, :creator_id
  end
end
