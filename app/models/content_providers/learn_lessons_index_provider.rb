module ContentProviders
  # Provides a view of current learning tools: videos and lessons
  class LearnLessonsIndexProvider < BitCore::ContentProvider
    DEFAULT_STUDY_LENGTH = 16
    DAYS_IN_WEEK = 7

    def render_current(options)
      membership = options.participant.active_membership

      options.view_context.render(
        template: "think_feel_do_engine/learn/lessons_index",
        locals: {
          weekly_tasks: weekly_tasks(options.participant,
                                     membership,
                                     options.app_context),
          week_in_study: membership.week_in_study,
          tool: content_module.tool
        }
      )
    end

    def show_nav_link?
      false
    end

    private

    def weekly_tasks(participant, membership, app_context)
      all_tasks = participant.learning_tasks(content_modules(app_context))
                  .includes(task: :bit_core_content_module)
                  .order("bit_core_content_modules.position")

      (1..week_count).map do |week|
        {
          date: membership.start_date + (week - 1) * DAYS_IN_WEEK,
          week: week,
          tasks: all_tasks
            .where(all_tasks.arel_table[:start_day]
                   .gt((week - 1) * DAYS_IN_WEEK))
            .where(all_tasks.arel_table[:start_day]
                   .lteq(week * DAYS_IN_WEEK))
        }
      end
    end

    def content_modules(app_context)
      ContentModules::LessonModule.joins(:tool)
        .where("bit_core_tools.title" => app_context)
        .where.not(id: bit_core_content_module_id)
    end

    def week_count
      Rails.application.config.study_length_in_weeks
    rescue
      DEFAULT_STUDY_LENGTH
    end
  end
end
