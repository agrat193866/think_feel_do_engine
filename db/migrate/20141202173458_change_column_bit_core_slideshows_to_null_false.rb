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
  end

  def down
    change_column_null :bit_core_slideshows, :arm_id, true

    BitCore::Slideshow.all.each do |slideshow|
      slideshow.arm_id = nil
      slideshow.save!
    end
  end
end
