module ThinkFeelDoEngine
  module Participants
    # Enables Participants to access Slideshows directly.
    class PublicSlidesController < ApplicationController
      def show
        @slideshow = BitCore::Slideshow.find(params[:slideshow_id])
        @slide = @slideshow.slides.find(params[:id])
      end
    end
  end
end
