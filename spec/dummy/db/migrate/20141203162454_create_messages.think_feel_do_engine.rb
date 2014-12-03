# This migration comes from think_feel_do_engine (originally 20140306161346)
class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :sender, polymorphic: true, index: true, null: false
      t.references :recipient, polymorphic: true, index: true, null: false
      t.string :subject, null: false
      t.text :body
      t.datetime :sent_at, null: false

      t.timestamps
    end
  end
end
