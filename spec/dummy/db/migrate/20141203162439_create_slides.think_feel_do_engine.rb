# This migration comes from think_feel_do_engine (originally 20140223151505)
class CreateSlides < ActiveRecord::Migration
  def up
    create_table :slides do |t|
      t.string :title
      t.text :body, null: false
      t.integer :position, null: false, default: 1
      t.references :slideshow, index: true, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE slides
            ADD CONSTRAINT fk_slides_slideshows
            FOREIGN KEY (slideshow_id)
            REFERENCES slideshows(id)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE slides
            DROP CONSTRAINT fk_slides_slideshows
        SQL
      end
    end
  end

  def down
  end
end
