class AddIsVizFlagToModules < ActiveRecord::Migration
  def change
    BitCore::ContentProvider.where(position: 1).all.each do |provider|
      if provider.try(:viz?)
        provider.content_module.update is_viz: true
      end
    end
  end
end
