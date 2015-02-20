module ThinkFeelDoEngine
  # Provides helpers for slide creation.
  module SlidesHelper
    # Returns table of contents creation or destroy
    # button based on slideshow attributes.
    def table_of_contents_link(arm, slideshow)
      if slideshow.has_table_of_contents?
        link_to "Destroy Table of Contents",
                arm_bit_maker_slideshow_destroy_table_of_contents_path(
                  arm,
                  slideshow),
                class: "btn btn-default toc"
      else
        link_to "Add Table of Contents",
                arm_bit_maker_slideshow_create_table_of_contents_path(
                  arm,
                  slideshow),
                class: "btn btn-default toc"
      end
    end

    def table_of_contents_display(slide)
      if slide.slideshow && slide.slideshow.has_table_of_contents &&
         1 == slide.position
        render "think_feel_do_engine/slides/table_of_contents", slide: slide
      end
    end
  end
end
