# Used to determine when a patient starts and completes learn task_statuses
class Engagement < ActiveRecord::Base
  belongs_to :task_status
end