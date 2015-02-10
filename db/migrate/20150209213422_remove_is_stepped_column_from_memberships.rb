class RemoveIsSteppedColumnFromMemberships < ActiveRecord::Migration
  def change
    remove_column :memberships, :is_stepped
  end
end
