module ContentProviders
  # Provides a form for a Participant to enter the most recent AwakePeriod.
  class AwakePeriodForm < BitCore::ContentProvider
    def render_current(options)
      participant = options.view_context.current_participant

      if participant.unfinished_awake_periods.exists?
        options.view_context.render(
          template: "think_feel_do_engine/awake_periods/incomplete",
          locals: {
            participant: participant
          }
        )
      else
        last_awake_time = participant.awake_periods.order("start_time").last
        options.view_context.render(
          template: "think_feel_do_engine/awake_periods/new",
          locals: {
            awake_period: participant.awake_periods.build,
            create_path: options.view_context.participant_data_path,
            participant: participant,
            wake_up_range: wake_up_range(last_awake_time),
            go_to_sleep_range: go_to_sleep_range(last_awake_time)
          }
        )
      end
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

    private

    def wake_up_range(last_awake_time)
      start_time = [
        # 1 hour after last going to sleep
        last_awake_time ? (last_awake_time.end_time + 1.hour) : Time.at(0),
        # 12am yesterday
        (Time.current - 1.day).at_beginning_of_day
      ].max
      end_time = Time.current - 2.hours

      (start_time.to_i..end_time.to_i).step(1.hour).to_a.map { |t| Time.at(t) }
    end

    def go_to_sleep_range(last_awake_time)
      start_time = [
        # 1am yesterday
        (Time.current - 1.day).at_beginning_of_day + 1.hour,
        # 2 hours after last going to sleep
        last_awake_time ? (last_awake_time.end_time + 2.hours) : Time.at(0)
      ].max
      end_time = Time.current - 1.hour

      (start_time.to_i..end_time.to_i).step(1.hour).to_a.map { |t| Time.at(t) }
    end
  end
end
