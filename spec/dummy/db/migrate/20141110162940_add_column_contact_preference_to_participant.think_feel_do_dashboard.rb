# This migration comes from think_feel_do_dashboard (originally 20141106211650)
class AddColumnContactPreferenceToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :contact_preference, :string, empty: true, default: ""
  end
end
