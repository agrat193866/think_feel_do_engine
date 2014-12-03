# This migration comes from think_feel_do_engine (originally 20140311182036)
class CreateEmotions < ActiveRecord::Migration
  def change
    create_table :emotions do |t|
      t.references :participant, index: true, null: false
      t.integer :rating
      t.string :type
      t.timestamps
    end
  end
end
