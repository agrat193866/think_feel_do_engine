# This migration comes from bit_player (originally 20140305234327)
class CreateBitPlayerSlides < ActiveRecord::Migration
  def change
    create_table :bit_player_slides do |t|
      t.string :title
      t.text :body, null: false
      t.integer :position, null: false, default: 1
      t.references :bit_player_slideshow, index: true, null: false
      t.string :type
      t.text :options
      t.boolean :is_title_visible, null: false, default: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_player_slides
            ADD CONSTRAINT fk_slides_slideshows
            FOREIGN KEY (bit_player_slideshow_id)
            REFERENCES bit_player_slideshows(id)
        SQL

        # make this constraint deferrable so that slide orders can be
        # updated
        execute <<-SQL
          ALTER TABLE bit_player_slides
            ADD CONSTRAINT bit_player_slide_position UNIQUE (bit_player_slideshow_id, position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_player_slides
            DROP CONSTRAINT fk_slides_slideshows
        SQL

        execute <<-SQL
          ALTER TABLE bit_player_slides
            DROP CONSTRAINT IF EXISTS bit_player_slide_position
        SQL
      end
    end
  end
end
