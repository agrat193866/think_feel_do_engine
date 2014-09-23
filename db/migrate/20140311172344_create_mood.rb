class CreateMood < ActiveRecord::Migration
  def change
    create_table :moods do |t|
      t.references :participant, index: true, null: false
      t.integer :rating
      t.timestamps
    end
  end
end