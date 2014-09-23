module ThinkFeelDoEngine
  module Participants
    # Enables Participants to access Slideshows directly.
    class SlidesController < ApplicationController
      before_action :authenticate_participant!

      def show
        @slideshow = BitCore::Slideshow.find(params[:slideshow_id])
        @slide = @slideshow.slides.find(params[:id])
      end
    end
  end
end
