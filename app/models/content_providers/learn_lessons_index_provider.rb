module ContentProviders
  # Provides a view of current learning tools: videos and lessons
  class LearnLessonsIndexProvider < BitCore::ContentProvider
    def render_current(options)
      assign_variables(options)
      options.view_context.render(
        template: "think_feel_do_engine/learn/lessons_index",
        locals: {
          all_tasks: @all_tasks,
          all_available_tasks: @all_available_tasks,
          oldest_unread_five: @oldest_unread_five,
          all_read_tasks: @all_read_tasks
        }
      )
    end

    def all_tasks
      @participant.learning_tasks(@content_modules)
    end

    def all_available_tasks
      all_tasks.available_for_learning(@participant.membership)
    end

    def archived_tasks
      @all_available_tasks.where.not(completed_at: nil)
    end

    def oldest_unread_five_tasks
      @all_available_tasks
        .where(completed_at: nil)
        .order(created_at: :asc)
        .limit(5)
    end

    def assign_variables(options)
      @participant = options.participant
      @content_modules = content_modules(options)
      @all_tasks = all_tasks
      @all_available_tasks = all_available_tasks
      @oldest_unread_five = oldest_unread_five_tasks
      @all_read_tasks = archived_tasks
    end

    def content_modules(options)
      ContentModules::LessonModule.joins(:tool)
        .where("bit_core_tools.title = ?", options.app_context)
        .where.not(id: bit_core_content_module_id)
    end

    def days_into_intervention(membership)
      time_diff = Time.current - membership.start_date
      days = time_diff / (3600 * 24)
      days.ceil
    end

    def show_nav_link?
      false
    end
  end
end
