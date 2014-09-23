class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :group, index: true
      t.references :bit_player_content_module, index: true
      t.boolean :is_complete, null: false, default: false

      t.timestamps
    end
  end
end
