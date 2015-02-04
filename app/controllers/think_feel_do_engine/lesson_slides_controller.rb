module ThinkFeelDoEngine
  # Enables slide CRUD functionality.
  class LessonSlidesController < ApplicationController
    before_action :authenticate_user!, :set_lesson, :set_arm
    before_action :set_slide, only: [:show, :edit, :update, :destroy]

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def new
      authorize! :new, BitCore::Slide
      @slide = @lesson.build_slide(slide_params)
    end

    def create
      authorize! :create, BitCore::Slide
      @slide = @lesson.build_slide(slide_params)

      if @slide.save
        redirect_to arm_lesson_path(@arm, @lesson),
                    notice: "Successfully created slide for lesson"
      else
        flash.now[:alert] = @slide.errors.full_messages.join(", ")
        render :new
      end
    end

    def show
      authorize! :show, BitCore::Slide
    end

    def edit
      authorize! :edit, BitCore::Slide
    end

    def update
      authorize! :update, BitCore::Slide

      if @slide.update(slide_params)
        redirect_to arm_lesson_path(@arm, @lesson),
                    notice: "Successfully updated slide for lesson"
      else
        flash.now[:alert] = @slide.errors.full_messages.join(", ")
        render :edit
      end
    end

    def destroy
      authorize! :destroy, BitCore::Slide

      if @lesson.destroy_slide(@slide)
        redirect_to arm_lesson_path(@arm, @lesson), notice: "Slide deleted"
      else
        redirect_to arm_lesson_path(@arm, @lesson), alert: "There were errors."
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

    def set_slide
      @slide = BitCore::Slide.find(params[:id])
    end

    def set_lesson
      @lesson = ContentModules::LessonModule.find(params[:lesson_id])
    end

    def set_arm
      @arm = Arm.find(params[:arm_id])
    end

    def slide_params
      if params[:slide] # why is this here? -Wehrley
        params
          .require(:slide)
          .permit(:body, :position, :title, :is_title_visible, :type,
                  options: [:vimeo_id])
      else
        {}
      end
    end

    def record_not_found
      redirect_to arm_lesson_path(@arm, @lesson),
                  alert: "Unable to find lesson content"
    end
  end
end
