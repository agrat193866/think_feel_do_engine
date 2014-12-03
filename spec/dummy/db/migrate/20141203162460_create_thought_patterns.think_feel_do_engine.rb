# This migration comes from think_feel_do_engine (originally 20140313025147)
class CreateThoughtPatterns < ActiveRecord::Migration
  def change
    create_table :thought_patterns do |t|
      t.string :title, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
