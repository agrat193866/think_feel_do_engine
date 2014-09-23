# This migration comes from bit_player (originally 20140620182756)
class BitPlayer::Slideshow < ActiveRecord::Base; end
class BitPlayer::Slide < ActiveRecord::Base; end
class BitPlayer::VideoSlide < BitPlayer::Slide; end

class ConvertSlidesSlideshowsToBitCore < ActiveRecord::Migration
  def up
    BitPlayer::Slideshow.all.each do |slideshow|
      BitCore::Slideshow.create!(title: slideshow.title, id: slideshow.id)
    end
    BitCore::ContentProviders::SlideshowProvider.all.each do |provider|
      provider.update!(source_content_type: "BitCore::Slideshow")
    end
    BitPlayer::Slide.all.each do |slide|
      type = (slide.type || "").gsub(/BitPlayer::VideoSlide/, "BitCore::VideoSlide")
      BitCore::Slide.create!(
        title: slide.title,
        id: slide.id,
        body: slide.body,
        position: slide.position,
        bit_core_slideshow_id: slide.bit_player_slideshow_id,
        type: type,
        options: slide.options,
        is_title_visible: slide.is_title_visible
      )
    end
    execute <<-SQL
      ALTER TABLE bit_player_slides
        DROP CONSTRAINT IF EXISTS fk_slides_slideshows
    SQL

    execute <<-SQL
      ALTER TABLE bit_player_slides
        DROP CONSTRAINT IF EXISTS bit_player_slide_position
    SQL
    drop_table :bit_player_slides
    drop_table :bit_player_slideshows
  end
end
