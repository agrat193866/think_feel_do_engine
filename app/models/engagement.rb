# Used to determine when a patient starts and completes learn task_statuses
class Engagement < ActiveRecord::Base
  belongs_to :task_status

  delegate :participant_id, to: :task_status, prefix: false
  delegate :participant, to: :task_status, prefix: false
end
