module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant completes a Task on the assigned day.
    class TaskCompletion
      def self.columns
        %w( participant_id title completed_on )
      end

      def self.all
        Participant.select(:id, :study_id)
          .includes(:memberships).map do |participant|
          next unless participant.active_membership

          TaskStatus.where(membership_id: participant.active_membership.id)
            .map do |task_status|
            next unless task_status.completed_at.try(:to_date) ==
                        participant.active_membership.start_date +
                        task_status.start_day - 1

            {
              participant_id: participant.study_id,
              title: task_status.task.title,
              completed_on: task_status.completed_at.to_date
            }
          end
        end.flatten.compact
      end
    end
  end
end
