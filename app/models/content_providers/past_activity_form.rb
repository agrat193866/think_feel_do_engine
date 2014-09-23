module ContentProviders
  # Provides multiple forms for a Participant to enter past Activities.
  class PastActivityForm < BitCore::ContentProvider
    def render_current(options)
      participant = options.view_context.current_participant
      options.view_context.render(
        template: "think_feel_do_engine/activities/past_activity_form",
        locals: {
          timestamps: timestamps(participant),
          activity: participant.activities.build,
          create_path: options.view_context.participant_data_path
        }
      )
    end

    def data_attributes
      [
        :start_time,
        :end_time,
        :activity_type_title,
        :actual_pleasure_intensity,
        :actual_accomplishment_intensity,
        :is_complete,
        :is_monitored
      ]
    end

    def data_class_name
      "Activity"
    end

    def show_nav_link?
      false
    end

    private

    def most_recent_awake_period(participant)
      if participant.unfinished_awake_periods.exists?
        participant.most_recent_unfinished_awake_period
      else
        participant.awake_periods.last
      end
    end

    def timestamps(participant)
      period = most_recent_awake_period(participant)
      start_time, end_time = period.start_time, period.end_time
      times = []
      (start_time.to_i .. (end_time.to_i - 1.hour)).step(1.hour) do |timestamp|
        times << timestamp
      end

      times
    end
  end
end
