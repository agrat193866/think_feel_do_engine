module ContentProviders
  # Selects a random slide from a slideshow to display.
  class RandomSlideProvider < BitCore::ContentProvider
    def render_current(options)
      slides = source_content.slides
      options.view_context.render(
        template: "think_feel_do_engine/slides/homepage",
        locals: {
          slide: slides.offset(rand(slides.count)).first
        }
      )
    end
  end
end
