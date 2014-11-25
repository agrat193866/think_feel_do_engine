module ThinkFeelDoEngine
  module BitMaker
    # Enables Admins to create, update, delete, and view the slideshow content
    class SlideshowsController < ApplicationController
      before_action :authenticate_user!, :set_arm
      before_action :build_slideshow, only: [:create]
      before_action :find_slideshow, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource except: [:index, :new]
      layout "manage"

      def index
        @slideshows = BitCore::Slideshow.all
        authorize! :index, @slideshows
      end

      def show
        @anchors = SlideshowAnchor
                   .where(bit_core_slideshow_id: @slideshow.id)
                   .group_by(&:target_name)
      end

      def new
        @slideshow = BitCore::Slideshow.new
        authorize! :create, @slideshow
      end

      def create
        if @slideshow.save
          @content_provider = BitCore::Tool
                              .find_or_create_by(title: "LEARN")
                              .add_module(@slideshow.title)
                              .add_content_provider(
                                "BitCore::ContentProviders::SlideshowProvider"
                              )
          @content_provider.update(source_content: @slideshow)
          redirect_to arm_bit_maker_slideshows_url(@arm),
                      notice: "Successfully created slideshow"
        else
          flash.now[:alert] = @slideshow.errors.full_messages.join(", ")
          render :new
        end
      end

      def edit
      end

      def update
        if @slideshow.update(slideshow_params)
          redirect_to arm_bit_maker_slideshows_url(@arm),
                      notice: "Successfully updated slideshow"
        else
          flash.now[:alert] = @slideshow.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @slideshow.destroy
          redirect_to arm_bit_maker_slideshows_url(@arm),
                      notice: "Slideshow deleted."
        else
          redirect_to arm_bit_maker_slideshows_url(@arm),
                      alert: @slideshow.errors.full_messages.join(", ")
        end
      end

      private

      # Needed b/c default CanCan looks for "Slideshow & @slideshow"
      def build_slideshow
        @slideshow = BitCore::Slideshow.new(slideshow_params)
      end

      # Needed b/c default CanCan looks for "Slideshow & @slideshow"
      def find_slideshow
        @slideshow = BitCore::Slideshow.find(params[:id])
      end

      def set_arm
        @arm = Arm.find(params[:arm_id])
      end

      def slideshow_params
        params.require(:slideshow).permit(:title) if params[:slideshow]
      end
    end
  end
end
