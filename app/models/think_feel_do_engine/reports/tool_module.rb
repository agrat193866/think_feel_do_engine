module ThinkFeelDoEngine
  module Reports
    # Helper methods for reporting on modules.
    module ToolModule
      URL_ROOT_RE = /^[^\/]*\/\/[^\/]+/

      def self.included(klass)
        class << klass
          def module_entries_map
            modules = BitCore::ContentModule.where(type: nil).map do |m|
              path = url_helpers.navigator_location_path(module_id: m.id)

              ["#{ path }", m.id]
            end

            Hash[modules]
          end

          # Returns a hash mapping path to Tool Module.
          def modules_map
            modules = BitCore::ContentModule.where(type: nil).map do |m|
              path = url_helpers.navigator_location_path(module_id: m.id)

              ["#{ path }", m]
            end

            Hash[modules]
          end

          def url_helpers
            ThinkFeelDoEngine::Engine.routes.url_helpers
          end
        end
      end
    end
  end
end
