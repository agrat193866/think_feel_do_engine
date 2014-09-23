module ContentProviders
  # Provides a set of links to ContentModules in the current context.
  class ModuleIndexProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/participants/content_modules/index",
        locals: {
          participant: options.participant,
          content_modules: content_modules(options)
        }
      )
    end

    def content_modules(options)
      BitCore::Tool.find_by_title(options.app_context)
        .content_modules
        .where.not(id: bit_core_content_module_id)
        .order(position: :asc)
    end

    def show_nav_link?
      false
    end
  end
end
