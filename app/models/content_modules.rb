module ContentModules
  # Methods for extending BitCore::ContentModule with scopes.
  module Scopes
    def didactic(group_id)
      didactic_module_ids = Task
                            .where(group_id: group_id,
                                   has_didactic_content: true)
                            .select(:id, :bit_core_content_module_id)
                            .map(&:bit_core_content_module_id)

      where(id: non_viz_module_ids & didactic_module_ids).select(:id)
    end

    def non_didactic(group_id)
      non_didactic_module_ids = Task.where(group_id: group_id,
                                           has_didactic_content: false)
                                .select(:id, :bit_core_content_module_id)
                                .map(&:bit_core_content_module_id)

      where(id: non_viz_module_ids & non_didactic_module_ids).select(:id)
    end

    def non_viz_module_ids
      @non_viz_module_ids ||= BitCore::ContentProvider
                              .extend(ContentProviders::Scopes)
                              .non_visualization
                              .map(&:bit_core_content_module_id)
    end
  end
end
