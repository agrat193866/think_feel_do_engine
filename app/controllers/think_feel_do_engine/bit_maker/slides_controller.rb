module ThinkFeelDoEngine
  module BitMaker
    # Enables admin to create, update, destroy, and reorder (sort) slides
    # Slides belong to slideshows
    class SlidesController < ApplicationController
      before_action :authenticate_user!
      before_action :find_slideshow, except: :index
      before_action :find_slide, only: [:show, :edit, :update, :destroy]

      load_and_authorize_resource only: [:show, :edit, :update, :destroy]

      layout "manage"

      def index
        @slideshows = BitCore::Slideshow.all
        authorize! :index, @slideshows
      end

      def new
        @slide = @slideshow.slides.build(type: params[:type])
        authorize! :create, @slide
      end

      def create
        @slide = @slideshow.slides.build(slide_params)
        authorize! :create, @slide
        @slide.position = @slideshow.slides.count + 1
        if @slide.save
          flash[:success] = "Successfully created slide for slideshow"
          redirect_to bit_maker_slideshow_path(@slideshow)
        else
          flash[:alert] = @slide.errors.full_messages.join(", ")
          render :new
        end
      end

      def show
        render "slides/show"
      end

      def edit
      end

      def update
        if @slide.update(slide_params)
          flash[:success] = "Successfully updated slide for slideshow"
          redirect_to bit_maker_slideshow_path(@slide.slideshow)
        else
          flash[:alert] = @slide.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @slide.destroy
          flash[:success] = "Slide deleted."
          redirect_to bit_maker_slideshow_path(@slide.slideshow)
        else
          flash[:error] = "There were errors."
          redirect_to bit_maker_slideshow_path(@slide.slideshow)
        end
      end

      def sort
        authorize! :update, BitCore::Slideshow
        if @slideshow.sort(params[:slide])
          flash.now[:success] = "Reorder was successful."
          render nothing: true
        else
          flash.now[:alert] = @slideshow.errors.full_messages.join(", ")
          render nothing: true
        end
      end

      private

      # Needed b/c default CanCan looks for "Slide & @slide"
      def find_slide
        @slide = BitCore::Slide.find(params[:id])
      end

      def find_slideshow
        @slideshow = BitCore::Slideshow.find(params[:slideshow_id])
      end

      def slide_params
        if params[:slide]
          params
            .require(:slide)
            .permit(:body, :position, :title, :is_title_visible, :type,
                    options: [:vimeo_id])
        end
      end
    end
  end
end
