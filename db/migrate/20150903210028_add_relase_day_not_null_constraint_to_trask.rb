class AddRelaseDayNotNullConstraintToTrask < ActiveRecord::Migration
  def change
    change_column_null :tasks, :release_day, false
  end
end
