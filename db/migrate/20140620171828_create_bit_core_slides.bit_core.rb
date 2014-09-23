# This migration comes from bit_core (originally 20140417174159)
class CreateBitCoreSlides < ActiveRecord::Migration
  def change
    create_table :bit_core_slides do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :position, null: false, default: 1
      t.integer :bit_core_slideshow_id, null: false
      t.string :type
      t.boolean :is_title_visible, null: false, default: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE bit_core_slides
            ADD CONSTRAINT bit_core_slide_position UNIQUE (bit_core_slideshow_id, position)
            DEFERRABLE INITIALLY IMMEDIATE
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_slides
            ADD CONSTRAINT fk_slideshows_slides
            FOREIGN KEY (bit_core_slideshow_id)
            REFERENCES bit_core_slideshows(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE bit_core_slides
            DROP CONSTRAINT fk_slideshows_slides
        SQL

        execute <<-SQL
          ALTER TABLE bit_core_slides
            DROP CONSTRAINT IF EXISTS bit_core_slide_position
        SQL
      end
    end
  end
end
