module ContentProviders
  # Provides a view of current learning tools: videos and lessons
  class LearnLessonsIndexProvider < BitCore::ContentProvider
    DAYS_IN_WEEK = 7

    def render_current(options)
      membership = options.participant.active_membership

      options.view_context.render(
        template: "think_feel_do_engine/learn/lessons_index",
        locals: {
          weekly_tasks: weekly_tasks(options.participant,
                                     membership,
                                     options.app_context),
          week_in_study: membership.week_in_study
        }
      )
    end

    def show_nav_link?
      false
    end

    private

    def weekly_tasks(participant, membership, app_context)
      all_tasks = participant.learning_tasks(content_modules(app_context))
      week_count = (membership.length_of_study / DAYS_IN_WEEK.to_f).ceil

      (1..week_count).map do |week|
        {
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
  end
end
