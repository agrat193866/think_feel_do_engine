class ConvertMessagesToolType < ActiveRecord::Migration
  def change
    BitCore::Tool.where(title: "MESSAGES").each do |tool|
      tool.update type: "Tools::Messages"
    end
  end
end
