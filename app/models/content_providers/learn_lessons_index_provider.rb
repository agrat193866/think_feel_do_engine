module ContentProviders
  # Provides a view of current learning tools: videos and lessons
  class LearnLessonsIndexProvider < BitCore::ContentProvider
    DAYS_IN_WEEK = 7

    def render_current(options)
      membership = options.participant.active_membership

      options.view_context.render(
        template: "think_feel_do_engine/learn/lessons_index",
        locals: {
          all_tasks: all_tasks(options.participant, options.app_context),
          membership: membership,
          week_count: (membership.length_of_study / DAYS_IN_WEEK.to_f).ceil
        }
      )
    end

    def show_nav_link?
      false
    end

    private

    def all_tasks(participant, app_context)
      participant.learning_tasks(content_modules(app_context))
    end

    def content_modules(app_context)
      ContentModules::LessonModule.joins(:tool)
        .where("bit_core_tools.title" => app_context)
        .where.not(id: bit_core_content_module_id)
    end
  end
end
