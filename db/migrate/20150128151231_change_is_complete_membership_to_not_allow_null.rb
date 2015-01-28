class ChangeIsCompleteMembershipToNotAllowNull < ActiveRecord::Migration
  def change
    change_column :memberships, :is_complete, :boolean, null: false
  end
end
