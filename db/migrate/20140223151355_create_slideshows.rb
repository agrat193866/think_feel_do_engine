class CreateSlideshows < ActiveRecord::Migration
  def up
    create_table :slideshows do |t|
      t.string :title, null: false

      t.timestamps
    end
  end

  def down
  end
end
