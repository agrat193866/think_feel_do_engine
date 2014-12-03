# This migration comes from think_feel_do_engine (originally 20140624163655)
class RenameColumnParticipantIdOnEmotionsToCreatorId < ActiveRecord::Migration
  def change
    rename_column :emotions, :participant_id, :creator_id
  end
end
