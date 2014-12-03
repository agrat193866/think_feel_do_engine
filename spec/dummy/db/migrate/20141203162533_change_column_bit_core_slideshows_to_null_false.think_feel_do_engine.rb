# This migration comes from think_feel_do_engine (originally 20141202173458)
class ChangeColumnBitCoreSlideshowsToNullFalse < ActiveRecord::Migration
  def up
    BitCore::Slideshow.all.each do |slideshow|
      if Arm.count > 0
        slideshow.arm_id = Arm.first.id
      else
        arm_for_orphaned_slideshows = Arm.find_or_create_by(title: "Arm for orphaned slideshows")
        slideshow.arm_id = arm_for_orphaned_slideshows.id        
      end
      slideshow.save!
    end

    change_column_null :bit_core_slideshows, :arm_id, false

    # add foreign key constaint
    execute <<-SQL
      ALTER TABLE bit_core_slideshows
        ADD CONSTRAINT fk_bit_core_slideshows_arms
        FOREIGN KEY (arm_id)
        REFERENCES arms(id)
    SQL
  end

  def down
    change_column_null :bit_core_slideshows, :arm_id, true

    BitCore::Slideshow.all.each do |slideshow|
      slideshow.arm_id = nil
      slideshow.save!
    end

    # remove foreign key constaint
    execute <<-SQL
      ALTER TABLE bit_core_slideshows
        DROP CONSTRAINT fk_bit_core_slideshows_arms
    SQL
  end
end
