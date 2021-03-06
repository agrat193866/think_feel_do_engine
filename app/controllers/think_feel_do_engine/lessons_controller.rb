module ThinkFeelDoEngine
  # Enables Lesson CRUD functionality.
  class LessonsController < ApplicationController
    before_action :authenticate_user!, :set_arm
    before_action :set_lessons, except: :sort
    before_action :set_lesson, only: [:show, :edit, :update, :destroy]
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def index
      authorize! :index, ContentModules::LessonModule
      @lessons = @lessons.includes(content_providers: :source_content)
                 .order(:position)
    end

    def all_content
      authorize! :index, ContentModules::LessonModule
      @slideshows = BitCore::Slideshow
                    .joins(content_provider: :content_module)
                    .merge(@lessons.order(:position))
      @slides = BitCore::Slide
                .where(bit_core_slideshow_id: @slideshows.map(&:id))
                .group_by(&:bit_core_slideshow_id)
    end

    def show
      authorize! :show, ContentModules::LessonModule
    end

    def new
      authorize! :new, ContentModules::LessonModule
      @lesson = build_lesson
    end

    def create
      authorize! :create, ContentModules::LessonModule
      lesson_tool = @arm.bit_core_tools.find_by_type("Tools::Learn")
      @lesson = lesson_tool.add_module(build_lesson)

      if @lesson.save
        redirect_to arm_lesson_url(@arm, @lesson),
                    notice: "Successfully created lesson"
      else
        flash.now[:alert] =
          "Unable to create lesson: " +
          model_errors(@lesson)
        render :new
      end
    end

    def edit
      authorize! :edit, ContentModules::LessonModule
    end

    def update
      authorize! :update, ContentModules::LessonModule

      if @lesson.update(lesson_params)
        redirect_to arm_lesson_url(@arm, @lesson),
                    notice: "Successfully updated lesson"
      else
        flash.now[:alert] =
          "Unable to update lesson: " +
          model_errors(@lesson)
        render :edit
      end
    end

    def destroy
      authorize! :destroy, ContentModules::LessonModule

      ContentModules::LessonModule.transaction do
        Task.where(bit_core_content_module_id: @lesson.id).destroy_all
        @lesson.destroy
      end

      redirect_to arm_lessons_url(@arm), notice: "Lesson deleted."

    rescue
      redirect_to arm_lessons_url(@arm),
                  alert: "Unable to delete lesson: #{ model_errors(@lesson) }"
    end

    def sort
      authorize! :update, ContentModules::LessonModule

      if ContentModules::LessonModule.sort(@arm.id, params[:lesson])
        flash.now[:success] = "Reorder was successful."
        render nothing: true
      else
        flash.now[:alert] = "Error while sorting."
        render nothing: true
      end
    end

    private

    def build_lesson
      ContentModules::LessonModule.new(lesson_params)
    end

    def lesson_params
      params.require(:lesson).permit(:title, :position) if params[:lesson]
    end

    def model_errors(model)
      model.try(:errors).try(:full_messages).try(:join, ", ")
    end

    def record_not_found
      redirect_to arm_lessons_url(@arm),
                  alert: "Unable to find lesson, please try again."
    end

    def set_arm
      @arm = Arm.find(params[:arm_id])
    end

    def set_lesson
      @lesson = @lessons.find(params[:id])
    end

    def set_lessons
      learn_tool_ids = @arm.bit_core_tools.where(type: "Tools::Learn").map(&:id)
      @lessons = ContentModules::LessonModule
                 .where(bit_core_tool_id: learn_tool_ids)
    end
  end
end
