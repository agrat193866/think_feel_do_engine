module ThinkFeelDoEngine
  module Coach
    # Provides helpers for color coding activities
    module ActivityColorCodeHelper
      # Returns a bootstrap table row class with an appropriate color
      # success - green
      # info - blue
      # warning - yellow
      # danger - red

      def get_color_class(activity)
        if activity.completed? && activity.rated?
          rating_color(
            activity.actual_pleasure_intensity,
            activity.actual_accomplishment_intensity
          )
        elsif activity.rated?
          rating_color(
            activity.actual_pleasure_intensity,
            activity.actual_accomplishment_intensity
          )
        else
          not_rated_color(activity)
        end
      end

      private

      def not_rated_color(activity)
        if activity.end_time && (Time.zone.now > activity.end_time)
          # Don't style, this is a past activity not marked as complete
          "no-color"
        else
          # Use predicted - activity is not yet been completed nor rated
          rating_color(
            activity.predicted_pleasure_intensity,
            activity.predicted_accomplishment_intensity
          )
        end
      end

      def rating_color(pleasure, accomplishment)
        return "no-color" if !pleasure || !accomplishment
        if pleasure >= 5
          accomplishment >= 5 ? "success" : "warning"
        else
          accomplishment >= 5 ? "info" : "danger"
        end
      end
    end
  end
end
