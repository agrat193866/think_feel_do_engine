module ThinkFeelDoEngine
  # Provide access to data exports.
  class ReportsController < ApplicationController
    before_action :authenticate_user!

    layout "manage"

    def index
      @reports = [
        { title: "Lesson Slide View", id: :lesson_slide_view },
        { title: "Lesson Viewing", id: :lesson_viewing },
        { title: "Module Page View", id: :module_page_view },
        { title: "Module Session", id: :module_session },
        { title: "Site Session", id: :site_session },
        { title: "Video Session", id: :video_session }
      ]
    end

    def show
      report = {
        lesson_slide_view: Reports::LessonSlideView,
        lesson_viewing: Reports::LessonViewing,
        module_page_view: Reports::ModulePageView,
        module_session: Reports::ModuleSession,
        site_session: Reports::SiteSession,
        video_session: Reports::VideoSession
      }[params[:id].to_sym]

      send_data report.to_csv, type: "text/csv"
    end
  end
end
