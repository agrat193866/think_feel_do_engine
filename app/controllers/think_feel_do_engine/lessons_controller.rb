module ThinkFeelDoEngine
  # Enables Lesson CRUD functionality.
  class LessonsController < ApplicationController
    before_action :authenticate_user!
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    layout "manage"

    def index
      authorize! :index, ContentModules::LessonModule
      @lessons = ContentModules::LessonModule.includes(:content_providers).order(:position)
    end

    def show
      authorize! :show, ContentModules::LessonModule
      @lesson = find_lesson
    end

    def new
      authorize! :new, ContentModules::LessonModule
      @lesson = build_lesson
    end

    def create
      authorize! :create, ContentModules::LessonModule
      lesson_tool = BitCore::Tool.find_or_create_by(title: "LEARN")
      @lesson = lesson_tool.add_module(build_lesson)

      if @lesson.save
        redirect_to lesson_url(@lesson), notice: "Successfully created lesson"
      else
        flash.now[:alert] = "Unable to create lesson: #{ model_errors(@lesson) }"
        render :new
      end
    end

    def edit
      authorize! :edit, ContentModules::LessonModule
      @lesson = find_lesson
    end

    def update
      authorize! :update, ContentModules::LessonModule
      @lesson = find_lesson

      if @lesson.update(lesson_params)
        redirect_to lesson_url(@lesson), notice: "Successfully updated lesson"
      else
        flash.now[:alert] = "Unable to update lesson: #{ model_errors(@lesson) }"
        render :edit
      end
    end

    def destroy
      authorize! :destroy, ContentModules::LessonModule
      @lesson = find_lesson

      ContentModules::LessonModule.transaction do
        Task.where(bit_core_content_module_id: @lesson.id).destroy_all
        @lesson.destroy
      end

      redirect_to lessons_url, notice: "Lesson deleted."

    rescue
      redirect_to lessons_url,
                  alert: "Unable to delete lesson: #{ model_errors(@lesson) }"
    end

    def sort
      authorize! :update, ContentModules::LessonModule
      if ContentModules::LessonModule.sort(params[:lesson])
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

    def find_lesson
      ContentModules::LessonModule.find(params[:id])
    end

    def lesson_params
      params.require(:lesson).permit(:title, :position) if params[:lesson]
    end

    def model_errors(model)
      model.try(:errors).try(:full_messages).try(:join, ", ")
    end

    def record_not_found
      redirect_to lessons_url, alert: "Unable to find lesson, please try again."
    end
  end
end
