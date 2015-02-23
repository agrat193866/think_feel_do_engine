module ThinkFeelDoEngine
  module Reports
    # Shared Lesson Module behavior.
    module LessonModule
      URL_ROOT_RE = /^[^\/]*\/\/[^\/]+/

      def self.included(klass)
        class << klass
          # Returns a hash mapping lesson entry (first slide) path to Lesson
          # Module id.
          def lesson_entries_map
            lessons = ContentModules::LessonModule.all.map do |m|
              first_provider_id = m.provider(1).try(:id)
              next unless first_provider_id

              path = navigator_location_path(module_id: m.id,
                                             provider_id: first_provider_id,
                                             content_position: 1)

              ["#{ path }", m.id]
            end.compact

            Hash[lessons]
          end

          # Returns a hash mapping path to Lesson Module id.
          def lessons_map
            lessons = ContentModules::LessonModule.all.map do |m|
              path = navigator_location_path(module_id: m.id)

              ["#{ path }", m.id]
            end

            Hash[lessons]
          end

          private

          def navigator_location_path(options)
            ThinkFeelDoEngine::Engine.routes.url_helpers
              .navigator_location_path(options)
          end
        end
      end
    end
  end
end
