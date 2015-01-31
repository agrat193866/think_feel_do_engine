class ConvertHomeToolType < ActiveRecord::Migration
  def change
    BitCore::Tool.where(title: "home").each do |tool|
      tool.update type: "Tools::Home"
    end
  end
end
