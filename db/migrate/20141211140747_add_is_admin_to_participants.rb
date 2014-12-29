class AddIsAdminToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :is_admin, :boolean, default: false
  end
end
