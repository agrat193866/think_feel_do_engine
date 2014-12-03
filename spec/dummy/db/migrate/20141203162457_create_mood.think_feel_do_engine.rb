# This migration comes from think_feel_do_engine (originally 20140311172344)
class CreateMood < ActiveRecord::Migration
  def change
    create_table :moods do |t|
      t.references :participant, index: true, null: false
      t.integer :rating
      t.timestamps
    end
  end
end