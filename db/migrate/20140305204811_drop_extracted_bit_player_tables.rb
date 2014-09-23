class DropExtractedBitPlayerTables < ActiveRecord::Migration
  def up
    drop_table :content_providers
    drop_table :content_modules
    drop_table :participant_statuses
    drop_table :slides
    drop_table :slideshows
  end
end
