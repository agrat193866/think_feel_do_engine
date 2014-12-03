# This migration comes from think_feel_do_engine (originally 20140505145843)
class AddStudyIdToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :study_id, :string
  end
end
