module ThinkFeelDoEngine
  # Enables slide CRUD functionality.
  class LessonSlidesController < ApplicationController
    before_action :authenticate_user!
    before_action :instantiate_lesson

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    layout "manage"

    def new
      authorize! :new, BitCore::Slide
      @slide = @lesson.build_slide(slide_params)
    end

    def create
      authorize! :create, BitCore::Slide
      @slide = @lesson.build_slide(slide_params)

      if @slide.save
        redirect_to lesson_path(@lesson),
                    notice: "Successfully created slide for lesson"
      else
        flash.now[:alert] = @slide.errors.full_messages.join(", ")
        render :new
      end
    end

    def show
      authorize! :show, BitCore::Slide
      @slide = find_slide
    end

    def edit
      authorize! :edit, BitCore::Slide
      @slide = find_slide
    end

    def update
      authorize! :update, BitCore::Slide
      @slide = find_slide

      if @slide.update(slide_params)
        redirect_to lesson_path(@lesson),
                    notice: "Successfully updated slide for lesson"
      else
        flash.now[:alert] = @slide.errors.full_messages.join(", ")
        render :edit
      end
    end

    def destroy
      authorize! :destroy, BitCore::Slide
      @slide = find_slide

      if @lesson.destroy_slide(@slide)
        redirect_to lesson_path(@lesson), notice: "Slide deleted"
      else
        redirect_to lesson_path(@lesson), alert: "There were errors."
      end
    end

    def sort
      authorize! :update, ContentModules::LessonModule
      if @lesson.sort(params[:slide])
        flash.now[:success] = "Reorder was successful."
        render nothing: true
      else
        flash.now[:alert] = @lesson.errors.full_messages.join(", ")
        render nothing: true
      end
    end

    private

    def find_slide
      BitCore::Slide.find(params[:id])
    end

    def instantiate_lesson
      @lesson = ContentModules::LessonModule.find(params[:lesson_id])
    end

    def slide_params
      if params[:slide]
        params
          .require(:slide)
          .permit(:body, :position, :title, :is_title_visible, :type,
                  options: [:vimeo_id])
      else
        {}
      end
    end

    def record_not_found
      redirect_to lesson_path(@lesson), alert: "Unable to find lesson content"
    end
  end
end
