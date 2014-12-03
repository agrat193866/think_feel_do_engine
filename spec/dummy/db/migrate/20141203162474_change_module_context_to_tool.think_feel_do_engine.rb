# This migration comes from think_feel_do_engine (originally 20140407202027)
# This migration comes from bit_player (originally 20140402225703)
class ChangeModuleContextToTool < ActiveRecord::Migration
  def up
    #add_column :bit_player_content_modules, :bit_player_tool_id, :integer
    #BitPlayer::ContentModule.reset_column_information
    #BitPlayer::ContentModule.all.each do |content_module|
    #  tool = BitPlayer::Tool.find_or_create_by_title(content_module.context)
    #  content_module.update!(bit_player_tool_id: tool.id)
    #end
    #change_column_null :bit_player_content_modules, :bit_player_tool_id, false
    #remove_column :bit_player_content_modules, :context
    #execute <<-SQL
    #  ALTER TABLE bit_player_content_modules
    #    ADD CONSTRAINT fk_content_modules_tools
    #    FOREIGN KEY (bit_player_tool_id)
    #    REFERENCES bit_player_tools(id)
    #SQL
  end

  def down
    #execute <<-SQL
    #  ALTER TABLE bit_player_content_modules
    #    DROP CONSTRAINT fk_content_modules_tools
    #SQL
    #add_column :bit_player_content_modules, :context, :string, null: false, default: "home"
    #BitPlayer::ContentModule.all.each do |content_module|
    #  content_module.update(context: content_module.tool.title)
    #end
    #remove_column :bit_player_content_modules, :bit_player_tool_id
  end
end
