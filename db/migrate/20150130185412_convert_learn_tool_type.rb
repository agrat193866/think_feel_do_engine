class ConvertLearnToolType < ActiveRecord::Migration
  def change
    BitCore::Tool.where(title: "LEARN").each do |tool|
      tool.update type: "Tools::Learn"
    end
  end
end
