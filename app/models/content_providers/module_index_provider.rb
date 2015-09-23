module ContentProviders
  # Provides a set of links to ContentModules in the current context.
  class ModuleIndexProvider < BitCore::ContentProvider
    def render_current(options)
      content_modules = get_content_modules(options)
      participant = options.participant

      options.view_context.render(
        template: "think_feel_do_engine/participants/content_modules/index",
        locals: {
          participant: participant,
          content_modules: content_modules,
          didactic_modules: content_modules.is_not_viz.is_didactic,
          non_didactic_modules: content_modules.is_not_viz.is_not_didactic,
          membership: options
                        .view_context
                        .view_membership(participant, participant.active_group)
        }
      )
    end

    def show_nav_link?
      false
    end

    private

    def get_content_modules(options)
      arm_id = options.participant.active_group.arm_id
      tool = BitCore::Tool.find_by_arm_id_and_title(arm_id, options.app_context)

      AvailableContentModule
        .for_participant(options.participant)
        .for_tool(tool)
        .available_by(Date.current)
        .excludes_module(bit_core_content_module_id)
        .is_not_terminated_on(Date.current)
        .latest_duplicate
    end
  end
end
