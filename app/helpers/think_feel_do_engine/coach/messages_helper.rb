module ThinkFeelDoEngine
  module Coach
    # Provides helpers for coach message composition.
    module MessagesHelper
      # Returns grouped options for selecting a section of the site.
      def grouped_options_for_site_link_select
        arm = @group.arm
        tools = arm.bit_core_tools.where(type: [nil, "Tools::Learn"])
        options = tools.map do |tool|
          title = tool.title
          context_options = modules_for_context(title).map do |m|
            [m.title, navigator_location_path(module_id: m.id)]
          end

          [title, context_options]
        end

        insert_intro_slideshow_anchor(options)
      end

      private

      def modules_for_context(c)
        BitCore::ContentModule
          .joins(:tool)
          .where("bit_core_tools.title = ?", c)
          .where.not("bit_core_content_modules.title = ''")
      end

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
