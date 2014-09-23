class CreateThoughtPatterns < ActiveRecord::Migration
  def change
    create_table :thought_patterns do |t|
      t.string :title, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
