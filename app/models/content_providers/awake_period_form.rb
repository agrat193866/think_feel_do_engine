module ContentProviders
  # Provides a form for a Participant to enter the most recent AwakePeriod.
  class AwakePeriodForm < BitCore::ContentProvider
    def render_current(options)
      participant = options.view_context.current_participant
      options.view_context.render(
        template: "think_feel_do_engine/awake_periods/new",
        locals: {
          awake_period: participant.awake_periods.build,
          create_path: options.view_context.participant_data_path,
          participant: participant
        }
      )
    end

    def data_class_name
      "AwakePeriod"
    end

    def data_attributes
      [:start_time, :end_time]
    end

    def show_nav_link?
      false
    end
  end
end
