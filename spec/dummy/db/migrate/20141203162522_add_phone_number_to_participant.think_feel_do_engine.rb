# This migration comes from think_feel_do_engine (originally 20141027181511)
class AddPhoneNumberToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :phone_number, :string
  end
end
