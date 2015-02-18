module ThinkFeelDoEngine
  module Coach
    # Provides helpers for coach message composition.
    module MessagesHelper
      # Returns grouped options for selecting a section of the site.
      def options_for_site_link_select
        tasks = @group.tasks
        options = tasks.map do |task|
          content_module = BitCore::ContentModule
                           .find(task.bit_core_content_module_id)
          title = content_module.title
          [title, navigator_location_path(module_id: content_module.id)]
        end

        insert_intro_slideshow_anchor(options)
      end

      private

      def insert_intro_slideshow_anchor(options)
        if (slideshow = SlideshowAnchor.fetch(:home_intro))
          path = ThinkFeelDoEngine::Engine.routes.url_helpers
                 .participants_public_slideshow_slide_path(
                   slideshow_id: slideshow.id,
                   id: slideshow.slides.first.id
                 )

          options.unshift(["Intro", [["Introduction to ThinkFeelDo", path]]])
        else
          options
        end
      end
    end
  end
end
