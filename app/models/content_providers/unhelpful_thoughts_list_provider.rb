module ContentProviders
  # Provides a list of a Participant's unhelpful Thoughts.
  class UnhelpfulThoughtsListProvider < BitCore::ContentProvider
    def data_class_name
      "Thought"
    end

    def render_current(options)
      @thoughts = options.participant.thoughts.unreflected
      @view = options.view_context
      @view.render(
        template: "think_feel_do_engine/thoughts/index",
        locals: {
          title: provider_title,
          thoughts: @thoughts.last(3),
          postscript: provider_postscript,
          show_nav_link: (@thoughts.count > 0)
        }
      )
    end

    def show_nav_link?
      false
    end

    private

    def provider_title
      if @thoughts.count > 0
        "You said you had the following unhelpful thoughts:"
      else
        "You don't have any harmful thoughts that you've logged and " \
        "haven't challenged."
      end
    end

    def provider_postscript
      if @thoughts.count > 0
        "We're going to ask you to challenge each thought:"
      else
        module_1 = BitCore::ContentModule.find_by_title("#1 Identifying")
        module_2 = BitCore::ContentModule.find_by_title("Add a New Thought")

        "You can log more thoughts in " +
        "#{ @view.link_to(
          "Think #1 Identifying",
          @view.navigator_location_path(module_id: module_1.id),
          style: "font-size: larger;") } or use " \
        "#{ @view.link_to(
          "Add a New Thought",
          @view.navigator_location_path(module_id: module_2.id),
          style: "font-size: larger;") } to do multiple steps at once."
      end
    end
  end
end
