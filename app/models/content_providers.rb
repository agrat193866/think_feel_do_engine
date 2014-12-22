module ContentProviders
  # Methods for extending BitCore::ContentProvider with scopes.
  module Scopes
    def non_visualization
      where(position: 1)
        .select(:id, :bit_core_content_module_id)
        .all.select { |p| !p.try(:viz?) }
    end
  end
end
