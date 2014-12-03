# This migration comes from think_feel_do_engine (originally 20140305220121)
# This migration comes from bit_player (originally 20140305200438)
class CreateBitPlayerContentModules < ActiveRecord::Migration
  def change
    create_table :bit_player_content_modules do |t|
      t.string :title, null: false
      t.string :context, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end
  end
end
