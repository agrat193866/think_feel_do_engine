class FixModuleVizColumns < ActiveRecord::Migration
  def change
    BitCore::ContentModule.reset_column_information

    BitCore::ContentProvider.where(type: %w( ContentProviders::PastDueActivitiesViz ContentProviders::ThoughtsDistortionVizProvider )).all.each do |provider|
      provider.content_module.update! is_viz: true
    end
  end
end
