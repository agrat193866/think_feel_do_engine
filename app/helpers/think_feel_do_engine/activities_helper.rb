module ThinkFeelDoEngine
  # Used to the average in difference between the actual
  # and predicted values of a collection of activities
  module ActivitiesHelper
    def average_intensity_difference(activities, attribute)
      count = 0
      total_diff = 0
      activities.each do |activity|
        actual_intensity = activity.send("actual_#{attribute}_intensity")
        predicted_intensity = activity.send("predicted_#{attribute}_intensity")
        if actual_intensity && predicted_intensity
          count += 1
          total_diff += (actual_intensity - predicted_intensity).abs
        end
      end
      count == 0 ? "No activities exist." : total_diff.to_f / count
    end

    def percent_complete_message(activities)
      "Completion Score: #{percent_complete(activities)}% "\
      "(You completed "\
      "#{activities.reviewed_and_complete.count} "\
      "out of #{scheduled_message(activities.were_planned)} "\
      "that you scheduled.)"
    end

    def percent_complete(activities)
      (
        activities.reviewed_and_complete.count.to_f /
        (activities.were_planned.count).to_f * 100
      ).round(0)
    end

    def scheduled_count(activities)
      activities.were_planned.count
    end

    def scheduled_message(activities)
      pluralize(scheduled_count(activities), "activity")
    end
  end
end