module ThinkFeelDoEngine
  module Reports
    # Helper methods for reporting on modules.
    module ToolModule
      URL_ROOT_RE = /^[^\/]*\/\/[^\/]+/

      def self.included(klass)
        class << klass
          # Returns a hash mapping path to Tool Module.
          def modules_map
            tool_modules.each_with_object({}) do |m, h|
              h[url_helpers.navigator_location_path(module_id: m.id)] = m
            end
          end

          private

          def tool_modules
            BitCore::ContentModule.where(type: nil)
          end

          def url_helpers
            ThinkFeelDoEngine::Engine.routes.url_helpers
          end
        end
      end
    end
  end
end
