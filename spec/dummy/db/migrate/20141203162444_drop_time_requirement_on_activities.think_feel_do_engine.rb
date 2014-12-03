# This migration comes from think_feel_do_engine (originally 20140226234059)
class DropTimeRequirementOnActivities < ActiveRecord::Migration
  def up
    change_column_null :activities, :start_time, true
    change_column_null :activities, :end_time, true
  end

  def down
  end
end
