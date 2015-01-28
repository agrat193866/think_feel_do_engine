class ChangeIsSteppedMembershipToNotAllowNull < ActiveRecord::Migration
  def change
    change_column :memberships, :is_stepped, :boolean, null: false
  end
end
