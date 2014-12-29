class AddColumnDisplayNameToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :display_name, :string
  end
end
