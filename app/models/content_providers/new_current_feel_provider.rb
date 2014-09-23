module ContentProviders
  # Participant rates their current mood
  class NewCurrentFeelProvider < BitCore::ContentProvider
    def render_current(options)
      options.view_context.render(
        template: "think_feel_do_engine/moods/new_current",
        locals: {
          mood: options.view_context.current_participant.moods.build,
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_class_name
      "Mood"
    end

    def data_attributes
      [:rating]
    end

    def show_nav_link?
      false
    end
  end
end
