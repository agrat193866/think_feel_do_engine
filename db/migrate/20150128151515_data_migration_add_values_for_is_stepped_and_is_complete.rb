class DataMigrationAddValuesForIsSteppedAndIsComplete < ActiveRecord::Migration
  def change
    Membership.all.each do |membership|
      end_of_trial = false
      if membership.end_date < Date.current
        end_of_trial = true
      end
      membership.update(is_stepped: false, is_complete: end_of_trial)
    end
  end
end
