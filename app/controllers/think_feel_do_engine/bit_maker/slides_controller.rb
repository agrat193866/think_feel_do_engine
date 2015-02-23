module ThinkFeelDoEngine
  module BitMaker
    # Enables admin to create, update, destroy, and reorder (sort) slides
    # Slides belong to slideshows
    class SlidesController < ApplicationController
      before_action :authenticate_user!, :set_arm
      before_action :find_slideshow, except: :preview
      before_action :find_slide, only: [:show, :edit, :update, :destroy]

      load_and_authorize_resource only: [:show, :edit, :update, :destroy]

      FIRST_SLIDE_POSITION = 1

      def index
        authorize! :index, @slideshow
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
          redirect_to arm_bit_maker_slideshow_path(@arm, @slideshow)
        else
          flash[:alert] = @slide.errors.full_messages.join(", ")
          render :new
        end
      end

      def create_table_of_contents
        toc_increment_slide_pos(@slideshow)

        @slide = @slideshow.slides.build(
          position: FIRST_SLIDE_POSITION,
          title: "Table of Contents",
          is_title_visible: true,
          body: "")
        authorize! :create, @slide

        if @slide.save
          @slideshow.update(has_table_of_contents: true)
          flash[:success] = "Successfully created table of contents for "\
          "slideshow."
          redirect_to arm_bit_maker_slideshow_path(@arm, @slideshow)
        else
          toc_decrement_slide_pos(@slideshow)
          flash[:alert] = @slide.errors.full_messages.join(", ")
          render :new
        end
      end

      def destroy_table_of_contents
        @slide = @slideshow.slides.where(position: FIRST_SLIDE_POSITION).first
        if @slide.destroy
          toc_decrement_slide_pos(@slideshow)
          @slideshow.update(has_table_of_contents: false)
          flash[:success] = "Table of contents deleted."
          redirect_to arm_bit_maker_slideshow_path(@arm, @slide.slideshow)
        else
          flash[:error] = "There were errors."
          redirect_to arm_bit_maker_slideshow_path(@arm, @slide.slideshow)
        end
      end

      def show
        if @slideshow.has_table_of_contents? &&
           FIRST_SLIDE_POSITION == @slide.position
          render "think_feel_do_engine/slides/"
        else
          render "think_feel_do_engine/slides/show"
        end
      end

      def edit
      end

      def update
        if @slide.update(slide_params)
          flash[:success] = "Successfully updated slide for slideshow"
          redirect_to arm_bit_maker_slideshow_path(@arm, @slide.slideshow)
        else
          flash[:alert] = @slide.errors.full_messages.join(", ")
          render :edit
        end
      end

      def destroy
        if @slide.destroy
          flash[:success] = "Slide deleted."
          redirect_to arm_bit_maker_slideshow_path(@arm, @slide.slideshow)
        else
          flash[:error] = "There were errors."
          redirect_to arm_bit_maker_slideshow_path(@arm, @slide.slideshow)
        end
      end

      def sort
        authorize! :update, BitCore::Slideshow
        first_slide = BitCore::Slide.find(params[:slide][0])

        if @slideshow.has_table_of_contents &&
           first_slide.title != "Table of Contents"
          flash[:alert] = "Table of contents cannot be moved out of"\
                              " the first position."
          render "think_feel_do_engine/slides/sort_with_reload.js"

        elsif @slideshow.sort(params[:slide])
          flash.now[:notice] = "Reorder was successful."
          render "think_feel_do_engine/slides/sort.js"
        else
          flash.now[:alert] = @slideshow.errors.full_messages.join(", ")
          render "think_feel_do_engine/slides/sort.js"
        end
      end

      def preview
        render text: Redcarpet::Markdown.new(
          Redcarpet::Render::HTML.new(
            filter_html: true,
            safe_links_only: true
          )
        ).render(params[:content] || "").html_safe
      end

      private

      # Needed b/c default CanCan looks for "Slide & @slide"
      def find_slide
        @slide = BitCore::Slide.find(params[:id])
      end

      def find_slideshow
        @slideshow = @arm.bit_core_slideshows.find(params[:slideshow_id])
      end

      def set_arm
        @arm = Arm.find(params[:arm_id])
      end

      def toc_increment_slide_pos(slideshow)
        slideshow.slides.order(:position).reverse_each do |slide|
          slide.update(position: slide.position + 1)
        end
      end

      def toc_decrement_slide_pos(slideshow)
        slideshow.slides.order(position: :asc).each do |slide|
          slide.update(position: slide.position - 1)
        end
      end

      def slide_params
        if params[:slide]
          params
            .require(:slide)
            .permit(:body, :position, :title, :is_title_visible, :type,
                    options: [:vimeo_id, :audio_url])
        end
      end
    end
  end
end
