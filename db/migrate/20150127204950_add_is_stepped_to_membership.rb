class AddIsSteppedToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :is_stepped, :boolean, default: false
  end
end
