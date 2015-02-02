class UpdateToolTypeColumns < ActiveRecord::Migration
  def change
    BitCore::Tool.reset_column_information

    BitCore::Tool.where(title: "MESSAGES").each do |tool|
      tool.update type: "Tools::Messages"
    end
    BitCore::Tool.where(title: "home").each do |tool|
      tool.update type: "Tools::Home"
    end
    BitCore::Tool.where(title: "LEARN").each do |tool|
      tool.update type: "Tools::Learn"
    end

    BitCore::ContentProvider.reset_column_information

    BitCore::ContentProvider.where(position: 1).all.each do |provider|
      if provider.try(:viz?)
        provider.content_module.update is_viz: true
      end
    end
  end
end
