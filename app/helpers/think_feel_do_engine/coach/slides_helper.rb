module ThinkFeelDoEngine
  module BitMaker
    # Provides helpers for slide creation.
    module SlidesHelper
      # Returns table of contents creation or destory button based on slideshow attributes.
      def table_of_contents_link(arm, slideshow)
        if slideshow.has_table_of_contents?
          link_to "Add Table of Contents",
                  create_table_of_contents_arm_bit_maker_slideshow_slide_path(arm, slideshow),
                  class: "btn btn-default"
        else
          link_to "Add Table of Contents",
                  create_table_of_contents_arm_bit_maker_slideshow_slide_path(arm, slideshow),
                  class: "btn btn-default"
        end
      end
    end
  end
end
