module ContentProviders
  # Methods for extending BitCore::ContentProvider with scopes.
  module Scopes
    def non_visualization
      where(position: 1)
        .select(:id, :position, :bit_core_content_module_id, :type)
        .all.reject { |p| p.try(:viz?) }
    end
  end
end
