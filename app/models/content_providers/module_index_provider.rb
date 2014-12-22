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
      arm_id = options.participant.active_group.arm_id
      tool = BitCore::Tool.find_by_arm_id_and_title(arm_id, options.app_context)

      BitCore::ContentModule.extend(ContentModules::Scopes)
        .where(bit_core_tool_id: tool.id)
        .where.not(id: bit_core_content_module_id)
        .order(position: :asc)
    end

    def show_nav_link?
      false
    end
  end
end
