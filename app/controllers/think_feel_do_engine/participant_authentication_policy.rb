module ThinkFeelDoEngine
  # Defines the behavior surrounding Participant authentication.
  class ParticipantAuthenticationPolicy
    def initialize(controller, participant)
      @controller = controller
      @participant = participant
    end

    def post_sign_in_path
      if @participant.sign_in_count == 1 &&
         (slideshow = SlideshowAnchor.fetch(:home_intro))
        ThinkFeelDoEngine::Engine.routes.url_helpers.participants_slideshow_slide_path(
          slideshow_id: slideshow.id,
          id: slideshow.slides.first.id
        )
      else
        "/"
      end
    end
  end
end
