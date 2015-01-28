class DestroyInvalidTaskStatuses < ActiveRecord::Migration
  def up
    TaskStatus.includes(:membership, :task)
              .all
              .each do |s|
                if s.membership.group_id != s.task.group_id
                  s.destroy
                end
              end
  end

  def down
  end
end
